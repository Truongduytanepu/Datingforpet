//
//  SceneDelegate.swift
//  PetDating
//
//  Created by Trương Duy Tân on 14/08/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // khởi tạo window từ window Scene
        
        window = UIWindow(windowScene: windowScene)
        
        //gán instance  window và viến window trong appdelegate
        (UIApplication.shared.delegate as? AppDelegate)?.window = window
        
        let isTutorialCompleted = UserDefaults.standard.bool(forKey: "tutorialCompleted")
        
        let isSetProfileUser = UserDefaults.standard.bool(forKey: "isSetProfileUser")
        
        let isSetProfilePet = UserDefaults.standard.bool(forKey: "isSetProfilePet")
        
        let isLogin = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        print("tutorialCompleted \(isTutorialCompleted)")
        print("isLoggedIn \(isLogin)")
        print("isSetProfileUser \(isSetProfileUser)")
        print("isSetProfilePet \(isSetProfilePet)")
        
        if !isTutorialCompleted {
            routeToTutorial()
        } else {
            if isLogin  {
                userHasProfile { hasProfile, hasPetInfo in
                    if hasProfile && hasPetInfo {
                        self.routeToMainController()
                    } else if hasProfile {
                        self.routeToPetProfile()
                    } else {
                        self.routeToUserProfile()
                    }
                }
            } else {
                routeToLogin()
            }
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}

extension SceneDelegate {
    // Chuyển đến màn hình tutorial
    func routeToTutorial(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tutorialVC = storyboard.instantiateViewController(withIdentifier: "TutorialViewController")
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else{return}
        window.rootViewController = tutorialVC
        window.makeKeyAndVisible()
        
    }
    
    // Chuyển đến màn hình Login
    func routeToLogin(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        let nav = UINavigationController(rootViewController: loginVC)
        nav.setNavigationBarHidden(true, animated: true)
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else{return}
        window.rootViewController = nav
        window.makeKeyAndVisible()
        
    }
    
    //Chuyển đến màn hình main
    func routeToMainController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let MainVC = storyboard.instantiateViewController(withIdentifier: "MainTabbarViewController")
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else{
            return
        }
        window.rootViewController = MainVC
        window.makeKeyAndVisible()
    }
    
    // CHuyển đến màn hình Setprofileuser
    func routeToUserProfile(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let UserVC = storyboard.instantiateViewController(withIdentifier: "SetProfileUserViewController")
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else{
            return
        }
        window.rootViewController = UserVC
        window.makeKeyAndVisible()
    }
    
    // Chuyển đến màn hình PetProfile
    func routeToPetProfile(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let petVC = storyboard.instantiateViewController(withIdentifier: "SetProfilePetViewController")
        guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else{
            return
        }
        window.rootViewController = petVC
        window.makeKeyAndVisible()
    }
    
    func userHasProfile(completion: @escaping (Bool, Bool) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            let databaseRef = Database.database().reference()
            databaseRef.child("user").child(currentUser.uid).observeSingleEvent(of: .value) { snapshot in
                if let userDict = snapshot.value as? [String: Any] {
                    let hasProfile = true
                    let hasPetInfo = userDict["pet"] != nil
                    completion(hasProfile, hasPetInfo)
                } else {
                    completion(false, false)
                }
            }
        } else {
            completion(false, false)
        }
    }
}
