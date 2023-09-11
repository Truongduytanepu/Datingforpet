//
//  UserViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 12/07/2023.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import Kingfisher
import AnimatedCollectionViewLayout

struct User {
    var userId: String
    var name: String
    var age: Int
    var location: String
    var pet: Pet?
    var image: String?
    var gender: String?
}

struct Pet {
    var image: String?
    var name: String?
    var age: Int?
    var gender: String?
    var type: String?
}

class UserViewController: UIViewController {
    
    private var users: [User] = []
    private var databaseRef = Database.database().reference()
    private var storageRef = Storage.storage().reference()
    private var currentUserId = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ẩn thanh điều hướng khi profileviewcontroller xuất hiện
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Thiết lập dataSource và delegate cho UICollectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Cấu hình UICollectionView, ví dụ: đăng ký cell tùy chỉnh
        collectionView.register(UINib(nibName: "TestCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TestCollectionViewCell")
        
        // Khởi tạo database reference và storage reference
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // Đổi layout của UICollectionView sang CustomCollectionViewLayout
        let layout = AnimatedCollectionViewLayout()
        collectionView.collectionViewLayout = layout
        
        layout.scrollDirection = .horizontal
        layout.animator = RotateInOutAttributesAnimator()
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        checkChange()
        fetchUserData()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func checkChange(){
        
        // Check lại giá trị của slider và shiwme
        if let currentUserId = currentUserId {
            let sliderRef = databaseRef.child("user").child(currentUserId).child("sliderValue")
            sliderRef.observe(.value) { [weak self] snapshot in
                self?.fetchUserData()
            }
        }
        
        if let currentUserId = currentUserId {
            let showMeRef = databaseRef.child("user").child(currentUserId).child("showMe")
            showMeRef.observe(.value) { [weak self] snapshot in
                self?.fetchUserData()
            }
        }
    }
    
    func fetchUserData() {
        databaseRef.child("user").observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let userDicts = snapshot.value as? [String: [String: Any]],
                  let currentUserId = self?.currentUserId else {
                return
            }
            
            var fetchedUsers: [User] = []
            
            for (userId, userDict) in userDicts {
                if userId == currentUserId {
                    continue // Loại bỏ người dùng đang đăng nhập
                }
                
                // Kiểm tra nếu người dùng hiện tại nằm trong danh sách followingIds hoặc danh sách notFollow
                if let currentUserInfo = userDicts[currentUserId],
                   let followingIds = currentUserInfo["followingIds"] as? [String],
                   let notFollowIds = currentUserInfo["notfollow"] as? [String] {
                    if followingIds.contains(userId) || notFollowIds.contains(userId) {
                        continue
                    }
                }
                
                // Lấy thông tin pet của người dùng đang xét
                if let petDict = userDict["pet"] as? [String: Any],
                   let petAge = petDict["age"] as? Int,
                   let petGender = petDict["gender"] as? String {
                    
                    // Kiểm tra gender của pet trùng với showMe của người dùng đăng nhập
                    if let currentUserInfo = userDicts[currentUserId],
                       let currentUserSliderValueDict = currentUserInfo["sliderValue"] as? [String: Any],
                       let currentUserLowerValue = currentUserSliderValueDict["lower"] as? Int,
                       let currentUserUpperValue = currentUserSliderValueDict["upper"] as? Int,
                       let currentUserShowMe = currentUserInfo["showMe"] as? String {
                        
                        // Kiểm tra tuổi thú cưng nằm giữa khoảng upper và lower
                        if petGender == currentUserShowMe && petAge >= currentUserLowerValue && petAge <= currentUserUpperValue {
                            let name = userDict["name"] as? String ?? ""
                            let age = userDict["age"] as? Int ?? 0
                            let location = userDict["location"] as? String ?? ""
                            let image = userDict["image"] as? String ?? ""
                            let gender = userDict["gender"] as? String ?? ""
                            var pet: Pet?
                            if let petImage = petDict["img"] as? String,
                               let petName = petDict["name"] as? String,
                               let petAge = petDict["age"] as? Int,
                               let petGender = petDict["gender"] as? String,
                               let petType = petDict["type"] as? String{
                                pet = Pet(image: petImage, name: petName, age: petAge, gender: petGender, type: petType)
                            }
                            let user = User(userId: userId, name: name, age: age, location: location, pet: pet, image: image, gender: gender)
                            fetchedUsers.append(user)
                        }
                    }
                }
            }
            self?.users = fetchedUsers
            self?.collectionView.reloadData()
        }
    }
}


extension UserViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TestCollectionViewCell", for: indexPath) as! TestCollectionViewCell
        
        let user = users[indexPath.item]
        
        cell.delegate = self
        cell.user = user
        cell.indexPath = indexPath
        
        return cell
    }
    
}

// Thêm extension UICollectionViewDelegate xử lý các tương tác và sự kiện trong UICollectionView
extension UserViewController: UICollectionViewDelegate {
    
}

extension UserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = collectionView.bounds
        return CGSize(width: screenSize.width, height: 720)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension UserViewController: TestCollectionViewCellDelegate{
    
    func petImageTapped(_ user: User) {
        let profileStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = profileStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileVC.isHideView = true
        profileVC.user = user
        profileVC.fetchUserProfile()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func matchUserHandle(user: User) {
        if let currentUserId = Auth.auth().currentUser?.uid {
            let userRef = Database.database().reference().child("user").child(currentUserId)
            let matchedUserRef = Database.database().reference().child("user").child(user.userId)
            
            userRef.child("followingIds").observeSingleEvent(of: .value) { snapshot in
                var followingIds = snapshot.value as? [String] ?? []
                followingIds.append(user.userId)
                
                // Cập nhật followingIds của người dùng đang đăng nhập
                userRef.child("followingIds").setValue(followingIds)
                
                userRef.child("followerIds").observeSingleEvent(of: .value) { snapshot in
                    let followerIds = snapshot.value as? [String] ?? []
                    let matchingIds = Set(followingIds).intersection(Set(followerIds))
                    
                    if !matchingIds.isEmpty {
                        // Lấy dữ liệu hiện có của matchIds của người dùng đang đăng nhập
                        userRef.child("matchIds").observeSingleEvent(of: .value) { matchSnapshot in
                            var matchIds = matchSnapshot.value as? [String] ?? []
                            
                            // Thêm UID của người dùng được match vào matchIds của người dùng đang đăng nhập
                            if !matchIds.contains(user.userId) {
                                matchIds.append(user.userId)
                            }
                            
                            // Cập nhật matchIds của người dùng đang đăng nhập
                            userRef.child("matchIds").setValue(matchIds) { error, _ in
                                if error == nil {
                                    self.addParticipantsToMatches()
                                    // Lấy dữ liệu hiện có của matchIds của người dùng được match
                                    matchedUserRef.child("matchIds").observeSingleEvent(of: .value) { matchedUserMatchSnapshot in
                                        var matchedUserMatchIds = matchedUserMatchSnapshot.value as? [String] ?? []
                                        
                                        // Thêm UID của người dùng đang đăng nhập vào matchIds của người dùng được match
                                        if !matchedUserMatchIds.contains(currentUserId) {
                                            matchedUserMatchIds.append(currentUserId)
                                        }
                                        
                                        // Cập nhật matchIds của người dùng được match
                                        matchedUserRef.child("matchIds").setValue(matchedUserMatchIds) { error, _ in
                                            if error == nil {
                                                // Sau khi cập nhật dữ liệu lên Firebase, gọi fetchUserData để tải lại dữ liệu từ Firebase
                                                self.fetchUserData()
                                            }
                                        }
                                    }
                                } else {
                                    print(error ?? "")
                                }
                            }
                        }
                    }
                }
            }
            
            matchedUserRef.child("followerIds").observeSingleEvent(of: .value) { followerSnapshot in
                var followerIds = followerSnapshot.value as? [String] ?? []
                followerIds.append(currentUserId)
                
                // Cập nhật followerIds của người dùng được match
                matchedUserRef.child("followerIds").setValue(followerIds) { error, _ in
                    if error == nil {
                        // Sau khi cập nhật dữ liệu lên Firebase, gọi fetchUserData để tải lại dữ liệu từ Firebase
                        self.fetchUserData()
                    }
                }
            }
        }
    }
    
    
    func addParticipantsToMatches() {
        if let currentUserId = currentUserId {
            let userMatchIdsRef = databaseRef.child("user").child(currentUserId).child("matchIds")
            
            // Sử dụng observeSingleEvent để lấy giá trị danh sách matchIds một lần duy nhất
            userMatchIdsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
                if let matchingIds = snapshot.value as? [String], let lastMatchingId = matchingIds.last {
                    print(lastMatchingId)
                    
                    let matchesRef = self?.databaseRef.child("matches")
                    let newMatchRef = matchesRef?.childByAutoId()
                    
                    // Tạo một mảng để đại diện cho participants
                    var participantsArray: [String] = []
                    
                    // Thêm người dùng hiện tại và lastMatchingId vào mảng
                    participantsArray.append(currentUserId)
                    participantsArray.append(lastMatchingId)
                    
                    print("☺️\(participantsArray)")
                    
                    // Kiểm tra xem participantsArray đã tồn tại trong danh sách matches chưa
                    self?.checkIfParticipantsExist(participantsArray, inMatches: matchesRef) { exists in
                        if !exists {
                            // Nếu participantsArray chưa tồn tại trong matches, thì mới thêm vào
                            newMatchRef?.child("participants").setValue(participantsArray) { (error, _) in
                                if let error = error {
                                    print("Không thể thêm participants: \(error)")
                                } else {
                                    print("Đã thêm participants thành công.")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkIfParticipantsExist(_ participants: [String], inMatches matchesRef: DatabaseReference?, completion: @escaping (Bool) -> Void) {
        // Kiểm tra xem participants đã tồn tại trong danh sách matches chưa
        matchesRef?.observeSingleEvent(of: .value) { snapshot in
            var exists = false
            
            if let matches = snapshot.value as? [String: Any] {
                for (_, matchData) in matches {
                    if let match = matchData as? [String: Any], let matchParticipants = match["participants"] as? [String] {
                        if Set(matchParticipants) == Set(participants) {
                            // participants đã tồn tại trong match
                            exists = true
                            break
                        }
                    }
                }
            }
            
            // Gọi closure với kết quả kiểm tra
            completion(exists)
        }
    }
    
    func unMatchUserhandle(user: User) {
        if let currentUserId = currentUserId {
            // Thêm UID của người dùng vào danh sách "notfollow" của người dùng đang đăng nhập
            let userRef = databaseRef.child("user").child(currentUserId)
            userRef.child("notfollow").observeSingleEvent(of: .value) { snapshot in
                var notFollowIds = snapshot.value as? [String] ?? []
                notFollowIds.append(user.userId)
                userRef.child("notfollow").setValue(notFollowIds) { error, _ in
                    if error == nil {
                        // Sau khi cập nhật dữ liệu lên Firebase, gọi fetchUserData để tải lại dữ liệu từ Firebase
                        self.fetchUserData()
                    }
                }
            }
        }
    }
}
extension UserViewController: ProfileTableViewCellDelegate{
    func showMeValueChange(selectedGender: String) {
        if let currentUserId = currentUserId {
            let showMeRef = databaseRef.child("user").child(currentUserId).child("showMe")
            showMeRef.setValue(selectedGender)
        }
    }
    
    func sliderValueChange(lowerValue: Int, upperValue: Int) {
        if let currentUserId = currentUserId {
            let sliderValueRef = databaseRef.child("user").child(currentUserId).child("sliderValue")
            let updatedSliderValue = ["lower": lowerValue, "upper": upperValue]
            sliderValueRef.setValue(updatedSliderValue)
        }
    }
    
    func editBtnTapped() {
        
    }
    
    func editBtnTappedPet() {
        
    }
}
