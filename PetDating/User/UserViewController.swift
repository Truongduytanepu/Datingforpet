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
        fetchUserData()
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func fetchUserData() {
        databaseRef.child("user").observe(.value) { [weak self] snapshot in
            guard let userDicts = snapshot.value as? [String: [String: Any]],
                  let currentUserShowMe = userDicts[self?.currentUserId ?? ""]?["showMe"] as? String,
                  let currentUserSliderValueDict = userDicts[self?.currentUserId ?? ""]?["sliderValue"] as? [String: Any],
                  let currentUserLowerValue = currentUserSliderValueDict["lower"] as? Int,
                  let currentUserUpperValue = currentUserSliderValueDict["upper"] as? Int else {
                return
            }
            
            var filteredUsers: [User] = []
            
            for (userId, userDict) in userDicts {
                if userId == self?.currentUserId {
                    continue
                }
                
                // Kiểm tra xem userDict có chứa trường "followingIds" và "notfollow" hay không
                let currentUserFollowingIds = userDict["followingIds"] as? [String] ?? []
                let currentUserNotFollow = userDict["notfollow"] as? [String] ?? []
                
                if !currentUserFollowingIds.contains(userId) && !currentUserNotFollow.contains(userId) {
                    if let petDict = userDict["pet"] as? [String: Any],
                       let petAge = petDict["age"] as? Int,
                       let petnGender = petDict["gender"] as? String {
                        if petAge >= currentUserLowerValue && petAge <= currentUserUpperValue && currentUserShowMe == petnGender {
                            let name = userDict["name"] as? String ?? ""
                            let age = userDict["age"] as? Int ?? 0
                            let location = userDict["location"] as? String ?? ""
                            let image = userDict["image"] as? String ?? ""
                            var pet: Pet?
                            if let petImage = petDict["img"] as? String {
                                pet = Pet(image: petImage)
                            }
                            let user = User(userId: userId, name: name, age: age, location: location, pet: pet, image: image)
                            filteredUsers.append(user)
                        }
                    }
                }
            }
            self?.users = filteredUsers
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
        return CGSize(width: screenSize.width, height: 350)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
