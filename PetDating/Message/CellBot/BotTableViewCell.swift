//
//  BotTableViewCell.swift
//  PetDating
//
//  Created by Trương Duy Tân on 17/08/2023.
//

import UIKit
import FirebaseDatabase
import Kingfisher

class BotTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var chatLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var imageUser: UIImageView!
    var databaseRef = Database.database().reference()
    var user: UserBot?
    var fetchLastMessage: ((String, @escaping(String?)-> Void)->Void)?
    var didSelectUser: ((UserBot) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageUser.layer.cornerRadius = imageUser.frame.height / 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @objc func cellTapped() {
        if let user = user {
            didSelectUser?(user)
        }
    }
    
    // Update this method to set the user data
    func configure(with selectedUser: UserBot, matchId: String) {
        nameLbl.text = selectedUser.name
        
        if let imageURL = URL(string: selectedUser.image) {
            let imageDefault = UIImage(named: "abc")
            
            // Tải và hiển thị ảnh người dùng bằng Kingfisher
            imageUser.kf.setImage(
                with: imageURL,
                placeholder: imageDefault)
        }
        
        if let fetchFunction = fetchLastMessage {
            // Gọi hàm fetchLastMessage để lấy tin nhắn cuối cùng
            fetchFunction(matchId) { lastMessage in
                DispatchQueue.main.async {
                    if let lastMessage = lastMessage, !lastMessage.isEmpty {
                        self.chatLbl.text = lastMessage
                    } else {
                        self.chatLbl.text = "No message"
                    }
                }
            }
        }
    }
}
