//
//  TopTableViewCell.swift
//  PetDating
//
//  Created by Trương Duy Tân on 17/08/2023.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TopTableViewCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let userRef = Database.database().reference()
    var matchIds: [String] = [] // Danh sách các matchIds
    var matchedUsers: [UserBot] = [] // Danh sách các người dùng đã match
    var currentUserID = Auth.auth().currentUser?.uid
    weak var messageViewController: MessageViewController?
    var didSelectUser: ((UserBot) -> Void)?
    var selectedUser: UserBot?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Đăng ký UICollectionViewCell cho identifier
        collectionView.register(UINib(nibName: "TopCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TopCollectionViewCell")
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 100, height: collectionView.frame.size.height)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    
    
    // Hàm này để cập nhật danh sách matchIds từ bên ngoài
    func updateMatchedUsers(_ matchedUsers: [UserBot]) {
        self.matchedUsers = matchedUsers
        collectionView.reloadData()
    }
    func configure(with users: [UserBot], didSelectUser: ((UserBot) -> Void)?) {
            self.matchedUsers = users
            self.didSelectUser = didSelectUser
            collectionView.reloadData()
        }
    
    func fetchMatchedUsers() {
        let matchesRef = userRef.child("matches")
        
        matchesRef.observeSingleEvent(of: .value) { [weak self] (snapshot: DataSnapshot) in
            var uniqueMatchedUsers: [UserBot] = [] // Danh sách người dùng đã match, loại bỏ các bản sao
            
            if let matchesData = snapshot.value as? [String: Any] {
                for (matchId, matchData) in matchesData {
                    // Chuyển đổi matchData sang kiểu Dictionary nếu có thể
                    if let matchDataDict = matchData as? [String: Any],
                       let participants = matchDataDict["participants"] as? [String] {
                        // Kiểm tra xem người dùng hiện tại có trong danh sách participants không
                        if participants.contains(self?.currentUserID ?? "") {
                            // Lặp qua danh sách participants và lấy thông tin của họ
                            for participant in participants {
                                // Kiểm tra xem participant có trùng với người dùng hiện tại không
                                if participant != self?.currentUserID {
                                    // Truy vấn thông tin người dùng từ Firebase
                                    self?.userRef.child("user").child(participant).observeSingleEvent(of: .value) { (userSnapshot) in
                                        if let userDict = userSnapshot.value as? [String: Any] {
                                            if let name = userDict["name"] as? String,
                                               let image = userDict["image"] as? String {
                                                let user = UserBot(uid: participant, name: name, image: image)
                                                
                                                // Kiểm tra xem người dùng đã tồn tại trong danh sách hay chưa
                                                if !uniqueMatchedUsers.contains(where: { $0.uid == user.uid }) {
                                                    uniqueMatchedUsers.append(user)
                                                }
                                            }
                                        }
                                        
                                        // Sau khi đã xử lý dữ liệu của một participant, cập nhật giao diện
                                        self?.updateMatchedUsers(uniqueMatchedUsers)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // Xử lý lỗi nếu không lấy được dữ liệu từ "matches"
                print("Error fetching matches data")
            }
        } withCancel: { (error: Error) in
            // Xử lý lỗi ở đây
        }
    }
}

extension TopTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedUser = matchedUsers[indexPath.item]
        didSelectUser?(selectedUser!)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return matchedUsers.count // Số lượng người dùng đã match
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCollectionViewCell", for: indexPath) as! TopCollectionViewCell
        // Lấy thông tin người dùng từ danh sách matchedUsers
        let user = matchedUsers[indexPath.item]
        cell.nameLbl.text = user.name
        if let imageURL = URL(string: user.image) {
            cell.userImage.kf.setImage(with: imageURL)
        }
        return cell
    }
}
