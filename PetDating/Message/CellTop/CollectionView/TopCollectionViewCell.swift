//
//  TopCollectionViewCell.swift
//  PetDating
//
//  Created by Trương Duy Tân on 17/08/2023.
//

import UIKit

class TopCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        userImage.layer.cornerRadius = userImage.frame.height / 2
    }
}
