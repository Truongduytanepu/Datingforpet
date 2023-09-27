//
//  NotNetworkViewController.swift
//  PetDating
//
//  Created by Trương Duy Tân on 27/09/2023.
//

import UIKit
import Reachability

class NotNetworkViewController: UIViewController {
    
    @IBOutlet weak var retry: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        retry.layer.borderWidth = 1.0
        retry.layer.cornerRadius = 5
        retry.layer.borderColor = UIColor(red: 0.766, green: 0.766, blue: 0.766, alpha: 1).cgColor
        retry.backgroundColor = UIColor(red: 250/255, green: 86/255, blue: 114/255, alpha: 1.0)
    }
    
    @IBAction func retryBtn(_ sender: Any) {
        // Kiểm tra trạng thái kết nối mạng
        if isNetworkReachable() {
            // Có kết nối mạng, bạn có thể thực hiện xử lý tải lại màn hình khác tại đây
            let isTutorialCompleted = UserDefaults.standard.bool(forKey: "tutorialCompleted")
            let isSetProfileUser = UserDefaults.standard.bool(forKey: "isSetProfileUser")
            let isSetProfilePet = UserDefaults.standard.bool(forKey: "isSetProfilePet")
            let isLogin = UserDefaults.standard.bool(forKey: "isLoggedIn")
            
            if !isTutorialCompleted {
                AppDelegate.scene?.routeToTutorial()
            } else {
                if isLogin {
                    AppDelegate.scene?.userHasProfile { hasProfile, hasPetInfo in
                        if hasProfile && hasPetInfo {
                            AppDelegate.scene?.routeToMainController()
                        } else if hasProfile {
                            AppDelegate.scene?.routeToPetProfile()
                        } else {
                            AppDelegate.scene?.routeToUserProfile()
                        }
                    }
                } else {
                    AppDelegate.scene?.routeToLogin()
                }
            }
        } else {
            // Không có kết nối mạng
            print("😂")
            // Hoặc bạn có thể thực hiện hướng điều hướng khác tại đây nếu cần
        }
    }
    
    func isNetworkReachable() -> Bool {
        let reachability = try? Reachability()
        return reachability?.isReachable ?? false
    }
}
