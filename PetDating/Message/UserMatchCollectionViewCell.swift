//
//  UserMatchCollectionViewCell.swift
//  PetDating
//
//  Created by Trương Duy Tân on 16/08/2023.
//

import UIKit

class UserMatchCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var image: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        image.layer.cornerRadius = image.frame.height/2
    }
}

