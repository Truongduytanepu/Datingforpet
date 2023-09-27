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
import MBProgressHUD
import SCLAlertView

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
        navigationController?.setNavigationBarHidden(true, animated: true)
        showLoading(isShow: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Thiết lập dataSource và delegate cho UICollectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Cấu hình UICollectionView, ví dụ: đăng ký cell tùy chỉnh
        collectionView.register(UINib(nibName: "TestCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TestCollectionViewCell")
        
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
    
    func showAlert() {
        // Tạo một cấu hình SCLAppearance để tùy chỉnh thông báo
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Message", target: self, selector: #selector(firstButton))
        alertView.showSuccess("Match Successful", subTitle: "You've successfully matched with another user!")
    }
    
    @objc func firstButton() {
        let messageVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageViewController") as! MessageViewController
        self.navigationController?.pushViewController(messageVC, animated: true)
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
        showLoading(isShow: true)
        
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
            self?.showLoading(isShow: false)
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
    func showLoading(isShow: Bool) {
        DispatchQueue.main.async {
            if isShow {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    func petImageTapped(_ user: User) {
        let profileStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = profileStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileVC.isHideView = true
        profileVC.user = user
        profileVC.fetchUserProfile()
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func matchUserHandle(user: User) {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            // Không có người dùng đăng nhập, không làm gì cả
            return
        }
        
        let userRef = databaseRef.child("user").child(currentUserId)
        let matchedUserRef = databaseRef.child("user").child(user.userId)
        
        // Thêm user.userId vào danh sách followingIds của người dùng đang đăng nhập
        addUserIdToFollowingIds(user.userId, in: userRef) {
            // Thêm currentUserId vào danh sách followerIds của người dùng được match
            self.addCurrentUserIdToFollowerIds(currentUserId, in: matchedUserRef) {
                // Kiểm tra trùng lặp giữa followingIds và followerIds
                self.checkAndAddMatchIds(in: userRef, and: matchedUserRef) { matchIdsChanged in
                    if matchIdsChanged {
                        // Nếu matchIds có thay đổi, thêm người dùng hiện tại và người được match vào danh sách participants
                        self.addParticipantsToMatches(userRef, matchedUserRef)
                        self.showAlert()
                    }
                    // Sau khi hoàn thành tất cả các bước, tải lại dữ liệu từ Firebase
                    self.fetchUserData()
                }
            }
        }
    }
    
    func addUserIdToFollowingIds(_ userId: String, in userRef: DatabaseReference, completion: @escaping () -> Void) {
        userRef.child("followingIds").observeSingleEvent(of: .value) { snapshot in
            var followingIds = snapshot.value as? [String] ?? []
            
            if !followingIds.contains(userId) {
                followingIds.append(userId)
                
                userRef.child("followingIds").setValue(followingIds) { error, _ in
                    if error == nil {
                        completion()
                    } else {
                        print(error ?? "")
                    }
                }
            } else {
                completion()
            }
        }
    }
    
    func addCurrentUserIdToFollowerIds(_ currentUserId: String, in matchedUserRef: DatabaseReference, completion: @escaping () -> Void) {
        matchedUserRef.child("followerIds").observeSingleEvent(of: .value) { snapshot in
            var followerIds = snapshot.value as? [String] ?? []
            
            if !followerIds.contains(currentUserId) {
                followerIds.append(currentUserId)
                
                matchedUserRef.child("followerIds").setValue(followerIds) { error, _ in
                    if error == nil {
                        completion()
                    } else {
                        print(error ?? "")
                    }
                }
            } else {
                completion()
            }
        }
    }
    
    func checkAndAddMatchIds(in userRef: DatabaseReference, and matchedUserRef: DatabaseReference, completion: @escaping (Bool) -> Void) {
        // Lấy danh sách followingIds của người dùng hiện tại
        userRef.child("followingIds").observeSingleEvent(of: .value) { followingSnapshot in
            guard let followingIds = followingSnapshot.value as? [String] else {
                // Không có followingIds, hoàn thành và không cần cập nhật
                completion(false)
                return
            }
            
            // Lấy danh sách followerIds của người dùng hiện tại
            userRef.child("followerIds").observeSingleEvent(of: .value) { followerSnapshot in
                guard let followerIds = followerSnapshot.value as? [String] else {
                    // Không có followerIds, hoàn thành và không cần cập nhật
                    completion(false)
                    return
                }
                
                // Tìm phần tử trùng nhau giữa followerIds và followingIds của người dùng hiện tại
                let matchingIds = Set(followerIds).intersection(Set(followingIds))
                
                // Lấy danh sách matchIds của người dùng hiện tại
                userRef.child("matchIds").observeSingleEvent(of: .value) { matchSnapshot in
                    var matchIds = matchSnapshot.value as? [String] ?? []
                    
                    // Thêm những phần tử trùng nhau từ danh sách matchingIds của người dùng hiện tại vào matchIds của người dùng đang đăng nhập
                    for matchingId in matchingIds {
                        if !matchIds.contains(matchingId) {
                            matchIds.append(matchingId)
                        }
                    }
                    
                    // Cập nhật danh sách matchIds của người dùng đang đăng nhập
                    userRef.child("matchIds").setValue(Array(matchIds)) { error, _ in
                        if error == nil {
                            // Lấy danh sách followingIds của người dùng được match
                            matchedUserRef.child("followingIds").observeSingleEvent(of: .value) { matchedFollowingSnapshot in
                                guard let matchedFollowingIds = matchedFollowingSnapshot.value as? [String] else {
                                    // Không có followingIds của người dùng được match, hoàn thành và không cần cập nhật
                                    completion(false)
                                    return
                                }
                                
                                // Lấy danh sách followerIds của người dùng được match
                                matchedUserRef.child("followerIds").observeSingleEvent(of: .value) { matchedFollowerSnapshot in
                                    guard let matchedFollowerIds = matchedFollowerSnapshot.value as? [String] else {
                                        // Không có followerIds của người dùng được match, hoàn thành và không cần cập nhật
                                        completion(false)
                                        return
                                    }
                                    
                                    // Tìm phần tử trùng nhau giữa followerIds và followingIds của người dùng được match
                                    let matchedMatchingIds = Set(matchedFollowerIds).intersection(Set(matchedFollowingIds))
                                    
                                    // Tạo một mảng mới để lưu trữ matchIds của người dùng được match
                                    var matchedUserMatchIds = [String]()
                                    
                                    // Thêm những phần tử trùng nhau từ danh sách matchedMatchingIds của người dùng được match vào matchedUserMatchIds
                                    for matchingId in matchedMatchingIds {
                                        if !matchedUserMatchIds.contains(matchingId) {
                                            matchedUserMatchIds.append(matchingId)
                                        }
                                    }
                                    
                                    // Cập nhật danh sách matchIds của người dùng được match
                                    matchedUserRef.child("matchIds").setValue(Array(matchedUserMatchIds)) { error, _ in
                                        if error != nil {
                                            print(error ?? "")
                                        } else {
                                            completion(matchSnapshot.value as? [String] != matchIds)
                                        }
                                    }
                                }
                            }
                        } else {
                            print(error ?? "")
                            completion(false)
                        }
                    }
                }
            }
        }
    }
    
    
    func addParticipantsToMatches(_ userRef: DatabaseReference, _ matchedUserRef: DatabaseReference) {
        // Lấy danh sách matchIds từ userRef
        userRef.child("matchIds").observeSingleEvent(of: .value) { matchSnapshot in
            guard let matchIds = matchSnapshot.value as? [String] else {
                // Không có matchIds, không làm gì cả
                return
            }
            
            // Lấy UID của người dùng hiện tại
            guard let currentUserId = Auth.auth().currentUser?.uid else {
                // Không có người dùng đăng nhập, không làm gì cả
                return
            }
            
            // Lấy phần tử cuối cùng của danh sách matchIds
            if let lastMatchId = matchIds.last {
                // Thêm phần tử cuối cùng của matchIds vào danh sách participants
                var participants: [String] = []
                participants.append(lastMatchId)
                participants.append(currentUserId)
                
                // Tạo một tham chiếu đến nhánh "matches" với childByAutoId
                let matchesRef = Database.database().reference().child("matches").childByAutoId()
                
                // Cập nhật danh sách participants của matchesRef
                matchesRef.child("participants").setValue(participants) { error, _ in
                    if error != nil {
                        print(error ?? "")
                    }
                }
            }
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
