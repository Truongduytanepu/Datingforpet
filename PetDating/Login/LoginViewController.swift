//
//  LoginViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 09/07/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SCLAlertView

class LoginViewController: UIViewController {
    
    @IBOutlet weak var hidePassword: UIButton!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var appleBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    var check: Bool = true
    var checkPassword: Bool = true
    let userRef = Database.database().reference().child("user")
    let currentUser = Auth.auth().currentUser
    @IBOutlet weak var btnRmm: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        emailTF.text = "abv@gmail.com"
        passwordTF.text = "123456"
    }
    
    @IBAction func hidePasswordHandle(_ sender: Any) {
        checkPassword = !checkPassword
        if checkPassword {
            passwordTF.isSecureTextEntry = true
            hidePassword.setImage(UIImage(named: "hide"), for: .normal)
        } else {
            passwordTF.isSecureTextEntry = false
            hidePassword.setImage(UIImage(named: "show"), for: .normal)
        }
    }
    
    @IBAction func checkRemember(_ sender: Any) {
        btnRmm.isSelected = !btnRmm.isSelected
        check = !check
        if check {
            btnRmm.setImage(UIImage(named: "unchecked"), for: .normal)
        } else {
            btnRmm.setImage(UIImage(named: "check"), for: .normal)
        }
    }
    
    @IBAction func createAccountHandle(_ sender: Any) {
        if let navigationController = navigationController {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let registerVC = mainStoryboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
            navigationController.pushViewController(registerVC, animated: true)
        }
    }
    @IBAction func signInWithGoogle(_ sender: Any) {
        showAlert()
    }
    @IBAction func signInWithApple(_ sender: Any) {
        showAlert()
    }
    @IBAction func signInWithFacebook(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func signInBtn(_ sender: Any) {
        showLoading(isShow: true)
        let email = emailTF.text ?? ""
        let password = passwordTF.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                let appearance = SCLAlertView.SCLAppearance(
                    showCircularIcon: true
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.showError("Sign in failure", subTitle: error.localizedDescription)
                return
            }else{
                // Đăng nhập thành công
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                AppDelegate.scene?.userHasProfile { hasProfile, hasPetInfo in
                    if hasProfile && hasPetInfo {
                        // Chuyển hướng người dùng vào màn hình chính
                        AppDelegate.scene?.routeToMainController()
                    } else if hasProfile {
                        // Chuyển hướng người dùng vào màn pet
                        AppDelegate.scene?.routeToPetProfile()
                    } else {
                        AppDelegate.scene?.routeToUserProfile()
                    }
                }
            }
        }
    }
    
    func setUpView(){
        // Thiết lập giao diện cho các nút và các phần tử UI khác
        setUpButton(button: appleBtn)
        setUpButton(button: facebookBtn)
        setUpButton(button: googleBtn)
        signInBtn.layer.cornerRadius = 25
    }
    
    func setUpButton(button: UIButton) {
        // Thiết lập giao diện cho các nút
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.setTitleColor(UIColor(red: 250/255, green: 86/255, blue: 114/255, alpha: 1.0), for: .normal)
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        button.clipsToBounds = true
    }
    
    func showAlert() {
        // Tạo một cấu hình SCLAppearance để tùy chỉnh thông báo
        let appearance = SCLAlertView.SCLAppearance(
            showCircularIcon: true
        )
        let alertView = SCLAlertView(appearance: appearance)
        alertView.showError("Error", subTitle: "The feature currently being developed is translation!")
    }
}
