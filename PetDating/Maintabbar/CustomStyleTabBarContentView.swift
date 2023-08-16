//
//  CustomStyleTabBarContentView.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 22/07/2023.
//

import Foundation
import ESTabBarController_swift

class CustomStyleTabBarContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        /// Normal
        iconColor = UIColor.lightGray
        
        /// Selected
        highlightIconColor = UIColor(red: 0.902, green: 0.38, blue: 0.459, alpha: 1)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

