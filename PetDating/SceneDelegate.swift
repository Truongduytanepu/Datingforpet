//
//  SceneDelegate.swift
//  PetDating
//
//  Created by Trương Duy Tân on 14/08/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // khởi tạo window từ window Scene
        
        window = UIWindow(windowScene: windowScene)
        
        //gán instance  window và viến window trong appdelegate
        (UIApplication.shared.delegate as? AppDelegate)?.window = window
        
        if UserDefaults.standard.bool(forKey: "tutorialCompleted") {
            // Người dùng đã hoàn thành màn hình hướng dẫn
            // Kiểm tra trạng thái đăng nhập và chuyển hướng đến màn hình chính (Main Screen)
            if UserDefaults.standard.bool(forKey: "isLoggedIn") {
                // Người dùng đã đăng nhập
                // Chuyển hướng đến màn hình chính (Main Screen)
                routeToMainController()
                
            } else {
                // Người dùng chưa đăng nhập
                routeToLogin()
                
            }
        } else {
            // Người dùng chưa hoàn thành màn hình hướng dẫn
            // Chuyển hướng đến màn hình hướng dẫn (Tutorial Screen)
            routeToTutorial()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    
}

extension SceneDelegate {
    // Chuyển đến màn hình tutorial
    private func routeToTutorial(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tutorialVC = storyboard.instantiateViewController(withIdentifier: "TutorialViewController")
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else{return}
        window.rootViewController = tutorialVC
        window.makeKeyAndVisible()
        
    }
    
    // Chuyển đến màn hình Login
    private func routeToLogin(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let nav = UINavigationController(rootViewController: loginVC)
        nav.setNavigationBarHidden(true, animated: true)
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else{return}
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
    }
    
    //Chuyển đến màn hình main
    private func routeToMainController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let MainVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarViewController")
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else{
            return
        }
        window.rootViewController = MainVC
        window.makeKeyAndVisible()
        
    }
}


