//
//  ItemCollectionViewCell.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 08/07/2023.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    var nextCallback: (() -> Void)?
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tutorialImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        nextBtn.setTitle("Skip", for: .normal)
        tutorialImage.image = nil
        titleLbl.text = nil
        nextBtn.layer.cornerRadius = 25
        nextBtn.clipsToBounds = true
    }
    
    @IBAction func handleBtnAction(_ sender: Any) {
        nextCallback?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tutorialImage.image = nil
        titleLbl.text = nil
    }
    
    func bindData(index: Int, image: String, title: String, nextCallback: (() -> Void)?) {
        nextBtn.setTitle("Continue", for: .normal)
        self.nextCallback = nextCallback
        tutorialImage.image = UIImage(named: image)
        titleLbl.text = title

    }
}
