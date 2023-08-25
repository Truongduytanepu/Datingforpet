//
//  TestCollectionViewCell.swift
//  FoodAppIOS
//
//  Created by apple on 8/3/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class TestCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var user: User? {
        didSet {
            if let user = user {
                nameLabel.text = user.name
                locationLabel.text = user.location
                if let userImage = user.image {
                    avatarImageView.kf.setImage(with: URL(string: userImage))
                } else {
                    avatarImageView.image = UIImage(systemName: "person.circle.fill")
                }
                
                if let petImage = user.pet?.image {
                    petImageView.kf.setImage(with: URL(string: petImage))
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = avatarImageView.bounds.height/2
        avatarImageView.layer.masksToBounds = true
        
        petImageView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor(red: 0.941, green: 0.949, blue: 0.961, alpha: 1).cgColor
        containerView.layer.cornerRadius = 10
        
        containerView.backgroundColor = UIColor(red: 0.941, green: 0.949, blue: 0.961, alpha: 1)
        
    }
    @IBAction func unMatchBtn(_ sender: Any) {
        if let user = user, let currentUserId = Auth.auth().currentUser?.uid {
            // Thêm UID của người dùng vào danh sách "notfollow" của người dùng đang đăng nhập
            let userRef = Database.database().reference().child("user").child(currentUserId)
            userRef.child("notfollow").observeSingleEvent(of: .value) { snapshot in
                var notFollowIds = snapshot.value as? [String] ?? []
                notFollowIds.append(user.userId)
                userRef.child("notfollow").setValue(notFollowIds)
            }
        }
    }
    @IBAction func matchBtn(_ sender: Any) {
        if let user = user, let currentUserId = Auth.auth().currentUser?.uid{
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
                matchedUserRef.child("followerIds").setValue(followerIds)
            }
        }
    }
}
