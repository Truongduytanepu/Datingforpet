////
////  UserCollectionViewCell.swift
////  PetDating
////
////  Created by Trương Duy Tân on 23/08/2023.
////
//
//import UIKit
//import Koloda
//
//class UserCollectionViewCell: UICollectionViewCell {
//
//    @IBOutlet weak var image: UIImageView!
//    var data = [UIImage?]()
//            
//    override func awakeFromNib() {
//           super.awakeFromNib()
////           koloda.dataSource = self
////           koloda.delegate = self
//       }
//   }
//
//   extension UserCollectionViewCell: KolodaViewDataSource, KolodaViewDelegate {
//       func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
//           return data.count
//       }
//       
//       func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
//           let imageView = UIImageView()
//           imageView.image = data[index]
//           imageView.contentMode = .scaleAspectFill
//           imageView.clipsToBounds = true
//           return imageView
//       }
//       
//       func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
//           return true
//       }
//   }
