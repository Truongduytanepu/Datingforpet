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

class User {
    var userId: String
    var name: String
    var age: Int
    var location: String
    var pet: Pet?
    var image: String?
    var gender: String?
    
    init(userId: String, name: String, age: Int, location: String, pet: Pet? = nil, image: String? = nil, gender: String? = nil) {
        self.userId = userId
        self.name = name
        self.age = age
        self.location = location
        self.pet = pet
        self.image = image
        self.gender = gender
    }
}

class Pet {
    var image: String?
    var name: String?
    var age: Int?
    var gender: String?
    var type: String?
    
    init(image: String? = nil, name: String? = nil, age: Int? = nil, gender: String? = nil, type: String? = nil) {
        self.image = image
        self.name = name
        self.age = age
        self.gender = gender
        self.type = type
    }
}

class UserViewController: UIViewController {
    
    var users: [User] = []
    var databaseRef: DatabaseReference!
    var storageRef = Storage.storage().reference()
    var currentUserId = Auth.auth().currentUser?.uid
    
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
        
        fetchUserData()
        
        checkChange()
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func checkChange(){
        
        // Check lại giá trị của slider và shiwme
        if let currentUserId = currentUserId {
            databaseRef.child("user").child(currentUserId).child("sliderValue").observe(.value) { [weak self] snapshot in
                self?.fetchUserData()
            }
        }
        
        if let currentUserId = currentUserId {
            databaseRef.child("user").child(currentUserId).child("showMe").observe(.value) { [weak self] snapshot in
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
        if let currentUserId = Auth.auth().currentUser?.uid{
            let userRef = Database.database().reference().child("user").child(currentUserId)
            userRef.child("followingIds").observeSingleEvent(of: .value){ snapshot in
                var followingIds = snapshot.value as? [String] ?? []
                followingIds.append(user.userId)
                userRef.child("followingIds").setValue(followingIds)
            }
            
            let matchedUserRef = Database.database().reference().child("user").child(user.userId)
            matchedUserRef.child("followerIds").observeSingleEvent(of: .value) { followerSnapshot in
                var followerIds = followerSnapshot.value as? [String] ?? []
                followerIds.append(currentUserId)
                matchedUserRef.child("followerIds").setValue(followerIds) { error, _ in
                    if error == nil {
                        // Sau khi cập nhật dữ liệu lên Firebase, gọi fetchUserData để tải lại dữ liệu từ Firebase
                        self.fetchUserData()
                    }
                }
            }
        }
    }
    
    func unMatchUserhandle(user: User) {
        if let currentUserId = Auth.auth().currentUser?.uid {
            // Thêm UID của người dùng vào danh sách "notfollow" của người dùng đang đăng nhập
            let userRef = Database.database().reference().child("user").child(currentUserId)
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
