//
//  MainTabbarViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 22/07/2023.
//

import UIKit
import ESTabBarController_swift

class MainTabbarViewController: ESTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        loadTabBarView()
        selectedIndex = 0
        navigationController?.isNavigationBarHidden = true
    }

    private func setupTabBarAppearance() {
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().tintColor = .clear
    }

    private func loadTabBarView() {
        let homeVC = createViewController(withIdentifier: "UserViewController", title: "", normalImage: "home", selectedImage: "selected_home")
        let home1VC = createViewController(withIdentifier: "MessageViewController", title: "", normalImage: "message", selectedImage: "selected_message")
        let home2VC = createViewController(withIdentifier: "ProfileViewController", title: "", normalImage: "user", selectedImage: "selected_user")
        
        setViewControllers([homeVC, home1VC, home2VC], animated: true)
    }

    private func createViewController(withIdentifier: String, title: String, normalImage: String, selectedImage: String) -> UIViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: withIdentifier)
        let normalImage = UIImage(named: normalImage)
        let selectedImage = UIImage(named: selectedImage)
        let normalTabBarItem = ESTabBarItem(CustomStyleTabBarContentView(), image: normalImage, selectedImage: nil)
        let selectedTabBarItem = ESTabBarItem(CustomStyleTabBarContentView(), image: selectedImage, selectedImage: nil)
        viewController.tabBarItem = normalTabBarItem
        
        // Khi tab được chọn, ta sẽ đặt lại tabBarItem để sử dụng ảnh được chọn
        viewController.tabBarItem = selectedTabBarItem
        
        let nav = AppNavigationController(rootViewController: viewController)
        return nav
    }
}
