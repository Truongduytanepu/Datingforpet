//
//  LoginViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 09/07/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

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
    @IBOutlet weak var btnRmm: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        emailTF.text = "truongduytanabcd@gmail.com"
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
    func setUpView(){
        setUpButton(button: appleBtn)
        setUpButton(button: facebookBtn)
        setUpButton(button: googleBtn)
        signInBtn.layer.cornerRadius = 25
    }
    
    func setUpButton(button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.cgColor
        button.setTitleColor(UIColor(red: 0.925, green: 0.42, blue: 0.588, alpha: 1), for: .normal)
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        button.clipsToBounds = true
    }
    @IBAction func createAccountHandle(_ sender: Any) {
        if let navigationController = navigationController {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let registerVC = mainStoryboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
            navigationController.pushViewController(registerVC, animated: true)
        }
    }
    @IBAction func signInBtn(_ sender: Any) {
        let email = emailTF.text ?? ""
        let password = passwordTF.text ?? ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            
            if let error = error {
                // Hiển thị thông báo lỗi đăng nhập cho người dùng, ví dụ:
                let alertController = UIAlertController(title: "Sign in failure", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                strongSelf.present(alertController, animated: true, completion: nil)
                return
            }else{
                
                // Đăng nhập thành công
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                //Kiểm tra xem người dùng đã có hồ sơ và thông tin về thú cưng hay chưa
                strongSelf.userHasProfile { hasProfile, hasPetInfo in
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    if hasProfile {
                        if hasPetInfo {
                            // Người dùng đã có hồ sơ và thông tin về thú cưng, chuyển hướng đến MainTabbarViewController
                            if let mainTabbarViewController = mainStoryboard.instantiateViewController(withIdentifier: "MainTabbarViewController") as? MainTabbarViewController {
                                strongSelf.navigationController?.pushViewController(mainTabbarViewController, animated: true)
                            }
                        } else {
                            // Người dùng đã có hồ sơ nhưng chưa có thông tin về thú cưng, chuyển hướng đến SetProfilePetViewController
                            if let setPetProfile = mainStoryboard.instantiateViewController(withIdentifier: "SetProfilePetViewController") as? SetProfilePetViewController {
                                strongSelf.navigationController?.pushViewController(setPetProfile, animated: true)
                            }
                        }
                    } else {
                        // Người dùng chưa có hồ sơ, chuyển hướng đến SetProfilePetViewController
                        if let setUserProfile = mainStoryboard.instantiateViewController(withIdentifier: "SetProfileUserViewController") as? SetProfileUserViewController {
                            strongSelf.navigationController?.pushViewController(setUserProfile, animated: true)
                        }
                    }
                    
                }
            }
        }
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
