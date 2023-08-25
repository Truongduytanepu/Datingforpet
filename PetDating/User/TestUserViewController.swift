////
////  TestUserViewController.swift
////  PetDating
////
////  Created by Trương Duy Tân on 23/08/2023.
////
//
//import UIKit
//import Koloda
//
//class TestUserViewController: UIViewController {
//
//    @IBOutlet weak var collectionView: UICollectionView!
//    var collectionViewOriginX: CGFloat = 0
//        var initialPanPosition: CGPoint = .zero
//
//    override func viewDidLoad() {
//            super.viewDidLoad()
//            collectionView.delegate = self
//            collectionView.dataSource = self
//            collectionView.register(UINib(nibName: "UserCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UserCollectionViewCell")
//
//            if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//                flowLayout.minimumLineSpacing = 0
//                flowLayout.minimumInteritemSpacing = 0
//
//                flowLayout.estimatedItemSize = .zero
//                flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//            }
//            collectionView.isPagingEnabled = true
//            collectionView.showsHorizontalScrollIndicator = false
//        }
//    }
//
//    extension TestUserViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            return 1 // Replace with actual number of items
//        }
//        
//        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCollectionViewCell", for: indexPath) as! UserCollectionViewCell
//            // Provide image data for the UserCollectionViewCell's data array
//            cell.data = [UIImage(named: "pexels-julissa-helmuth-3196887"), UIImage(named: "tutorial00"), UIImage(named: "tutorial000")]
////            cell.koloda.reloadData() // Reload data in KolodaView
//            return cell
//        }
//    }
