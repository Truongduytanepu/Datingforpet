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
    weak var messageViewController: MessageViewController?
    var users: [UserBot] = []
    
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
    func updateUsers(_ users: [UserBot]) {
        self.users = users
        collectionView.reloadData()
    }
}

extension TopTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopCollectionViewCell", for: indexPath) as! TopCollectionViewCell

        // Lấy thông tin người dùng từ danh sách users
        let user = users[indexPath.item]

        cell.nameLbl.text = user.name

        if let imageURL = URL(string: user.image) {
            cell.userImage.kf.setImage(with: imageURL)
        }

        return cell
    }
}
