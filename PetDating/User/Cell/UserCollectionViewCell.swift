//
//  UserCollectionViewCell.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 19/07/2023.
//

import UIKit

class UserCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageOwn: UIImageView!
    
    @IBOutlet weak var match: UIButton!
    @IBOutlet weak var unMatch: UIButton!
    @IBOutlet weak var imagePet: UIImageView!
    @IBOutlet weak var locationOwnLbl: UILabel!
    @IBOutlet weak var nameOwnLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        imageOwn.layer.cornerRadius = imageOwn.frame.height / 2
//        imagePet.layer.cornerRadius = 20
//        unMatch.layer.borderColor = UIColor.red.cgColor
//        unMatch.layer.cornerRadius = unMatch.frame.height / 2
//        match.layer.borderColor = UIColor(red: 0.388, green: 0.847, blue: 0.627, alpha: 1).cgColor
//        match.layer.cornerRadius = match.frame.height / 2
//        match.layer.borderWidth = 1
//        unMatch.layer.borderWidth = 1
    }
    
}
