//
//  ShowLoading.swift
//  PetDating
//
//  Created by Trương Duy Tân on 29/09/2023.
//

import UIKit
import MBProgressHUD

extension UIViewController {
    func showLoading(isShow: Bool) {
        if isShow {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        } else {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}
