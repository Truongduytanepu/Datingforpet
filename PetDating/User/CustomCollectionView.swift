//
//  CustomCollectionView.swift
//  PetDating
//
//  Created by Trương Duy Tân on 25/08/2023.
//

import Foundation
import AnimatedCollectionViewLayout

class CustomCollectionViewLayout: AnimatedCollectionViewLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let layoutAttributes = layoutAttributesForElements(in: collectionView!.bounds)
        
        let centerOffsetX = collectionView!.bounds.size.width / 2
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        
        for attributes in layoutAttributes! {
            let itemCenterX = attributes.center.x
            let distance = itemCenterX - collectionView!.contentOffset.x - centerOffsetX
            
            if abs(distance) < abs(offsetAdjustment) {
                offsetAdjustment = distance
            }
        }
        
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
}
