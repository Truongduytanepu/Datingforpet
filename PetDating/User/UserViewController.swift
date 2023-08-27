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
    
    init(userId: String, name: String, age: Int, location: String, pet: Pet? = nil, image: String? = nil) {
        self.userId = userId
        self.name = name
        self.age = age
        self.location = location
        self.pet = pet
        self.image = image
    }
}

class Pet {
    var image: String?
    
    init(image: String? = nil) {
        self.image = image
    }
}

class UserViewController: UIViewController {
    
    var users: [User] = []
    var databaseRef: DatabaseReference!
    var storageRef = Storage.storage().reference()
    var currentUserId = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // Thiết lập dataSource và delegate cho UICollectionView
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
        }
        
        // Cấu hình UICollectionView, ví dụ: đăng ký cell tùy chỉnh
        collectionView.register(UINib(nibName: "TestCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TestCollectionViewCell")
        
        // Khởi tạo database reference và storage reference
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        // Lấy dữ liệu người dùng từ Firebase
        
        
        // Đổi layout của UICollectionView sang CustomCollectionViewLayout
        let layout = AnimatedCollectionViewLayout()
        collectionView.collectionViewLayout = layout
        
        layout.scrollDirection = .horizontal
        layout.animator = RotateInOutAttributesAnimator()
        
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        
        fetchUserData()
        
        self.navigationController?.isNavigationBarHidden = true
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
                            var pet: Pet?
                            if let petImage = petDict["img"] as? String {
                                pet = Pet(image: petImage)
                            }
                            let user = User(userId: userId, name: name, age: age, location: location, pet: pet, image: image)
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
