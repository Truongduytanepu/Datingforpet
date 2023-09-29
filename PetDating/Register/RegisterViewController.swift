//
//  RegisterViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 09/07/2023.
//

import UIKit
import FirebaseAuth
import SCLAlertView

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var hidePassword2: UIButton!
    @IBOutlet weak var hidePassword1: UIButton!
    @IBOutlet weak var btnRmm: UIButton!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    
    var check: Bool = true
    var checkPassword1: Bool = true
    var checkPassword2: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpBtn.layer.cornerRadius = 25
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func showPasswordHandle(_ sender: Any) {
        checkPassword1 = !checkPassword1
        if checkPassword1 {
            passwordTF.isSecureTextEntry = true
            hidePassword1.setImage(UIImage(named: "hide"), for: .normal)
        } else {
            passwordTF.isSecureTextEntry = false
            hidePassword1.setImage(UIImage(named: "show"), for: .normal)
        }
    }
    
    @IBAction func showPasswordHandle1(_ sender: Any) {
        checkPassword2 = !checkPassword2
        if checkPassword2 {
            confirmPasswordTF.isSecureTextEntry = true
            hidePassword2.setImage(UIImage(named: "hide"), for: .normal)
        } else {
            confirmPasswordTF.isSecureTextEntry = false
            hidePassword2.setImage(UIImage(named: "show"), for: .normal)
        }
    }
    
    @IBAction func rememberCheck(_ sender: Any) {
        check = !check
        if check {
            btnRmm.setImage(UIImage(named: "unchecked"), for: .normal)
        } else {
            btnRmm.setImage(UIImage(named: "check"), for: .normal)
        }
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func handleSignUp(_ sender: Any) {
        let email = emailTF.text ?? ""
        let password = passwordTF.text ?? ""
        let confirmPassword = confirmPasswordTF.text ?? ""
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            if password == confirmPassword {
                if let error = error {
                    SCLAlertView.showErrorAlert(title: "Sign up failure", message: error.localizedDescription)
                } else {
                    // Đăng ký thành công
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    if UserDefaults.standard.bool(forKey: "isSetProfileUser"){
                        if UserDefaults.standard.bool(forKey: "isSetProfilePet"){
                            AppDelegate.scene?.routeToMainController()
                        }else{
                            AppDelegate.scene?.routeToPetProfile()
                        }
                    }else{
                        AppDelegate.scene?.routeToUserProfile()
                    }
                    
                }
            } else {
                SCLAlertView.showErrorAlert(title: "Sign up failure", message: error?.localizedDescription ?? "Confirm password doesn't match.")
                return
            }
        }
    }
}

extension SCLAlertView {
    static func showErrorAlert(title: String, message: String) {
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.showError(title, subTitle: message)
    }
}
