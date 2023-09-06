//
//  BotTableViewCell.swift
//  PetDating
//
//  Created by Trương Duy Tân on 17/08/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

class BotTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var chatLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imageUser: UIImageView!
    var databaseRef = Database.database().reference()
    var user: UserBot?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            imageUser.layer.cornerRadius = imageUser.frame.height / 2
        }

        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
        }
        
        // Update this method to set the user data
    func configure(with user: UserBot) {
            nameLbl.text = user.name
            
            if let imageURL = URL(string: user.image) {
                let imageDefault = UIImage(named: "abc")
                
                // Tải và hiển thị ảnh người dùng bằng Kingfisher
                imageUser.kf.setImage(
                    with: imageURL,
                    placeholder: imageDefault)
            }
        }
    }
