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
        iconColor = UIColor.black

        /// Selected
        highlightIconColor = UIColor(red: 250/255, green: 86/255, blue: 114/255, alpha: 1.0)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
