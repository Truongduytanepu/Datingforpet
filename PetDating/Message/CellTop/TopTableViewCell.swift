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
    var currentUserID = Auth.auth().currentUser?.uid // ID của người dùng hiện tại
    weak var messageViewController: MessageViewController?
    
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
    func updateMatchIds(_ matchIds: [String], currentUserID: String?) {
        self.matchIds = matchIds
        self.currentUserID = currentUserID
        // Sau khi cập nhật danh sách matchIds, gọi hàm để lấy thông tin người dùng từ matchIds
        fetchMatchedUsers()
    }
    func fetchMatchedUsers() {
        let userMatchIdsRef = userRef.child("user").child(currentUserID!)
        
        userMatchIdsRef.observeSingleEvent(of: .value) { [weak self] (snapshot) in
            if let matchIdsDict = snapshot.value as? [String: Any],
               let matchIdsArray = matchIdsDict["matchIds"] as? [String] {
                print("😌\(matchIdsArray)")
                
                var processedMatchIdsCount = 0 // Số lượng matchId đã được xử lý
                var uniqueMatchedUsers: [UserBot] = [] // Danh sách người dùng đã match, loại bỏ các bản sao
                
                // Lặp qua danh sách matchIds
                for matchId in matchIdsArray {
                    // Truy vấn thông tin người dùng từ matchId
                    self?.userRef.child("user").child(matchId).observeSingleEvent(of: .value) { (userSnapshot) in
                        if let userDict = userSnapshot.value as? [String: Any] {
                            if let name = userDict["name"] as? String,
                               let image = userDict["image"] as? String {
                                let user = UserBot(uid: matchId, name: name, image: image)
                                
                                // Kiểm tra xem người dùng đã tồn tại trong danh sách hay chưa
                                if !uniqueMatchedUsers.contains(where: { $0.uid == user.uid }) {
                                    uniqueMatchedUsers.append(user)
                                }
                                
                                // Tăng số lượng matchId đã được xử lý
                                processedMatchIdsCount += 1
                                
                                // Kiểm tra xem đã xử lý tất cả các matchId chưa
                                if processedMatchIdsCount == matchIdsArray.count {
                                    // Sau khi đã xử lý tất cả các matchId, cập nhật giao diện
                                    self?.matchedUsers = uniqueMatchedUsers
                                    self?.collectionView.reloadData()
                                }
                            }
                        } else {
                            // Xử lý lỗi nếu truy vấn không thành công
                            print("Error fetching user data for matchId: \(matchId)")
                            
                            // Tăng số lượng matchId đã được xử lý
                            processedMatchIdsCount += 1
                            
                            // Kiểm tra xem đã xử lý tất cả các matchId chưa
                            if processedMatchIdsCount == matchIdsArray.count {
                                // Sau khi đã xử lý tất cả các matchId, cập nhật giao diện
                                self?.matchedUsers = uniqueMatchedUsers
                                self?.collectionView.reloadData()
                            }
                        }
                    }
                }
            } else {
                // Xử lý lỗi nếu không lấy được danh sách matchIds
                print("Error fetching matchIds")
            }
        }
    }
}
extension TopTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
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
