//
//  TestCollectionViewCell.swift
//  FoodAppIOS
//
//  Created by apple on 8/3/23.
//

import UIKit

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

}
