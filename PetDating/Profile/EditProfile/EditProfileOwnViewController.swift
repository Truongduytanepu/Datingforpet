//
//  EditProfileOwnViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 26/07/2023.
//

import UIKit
import FirebaseDatabase

class EditProfileOwnViewController: UIViewController {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var genderTF: UITextField!
    var currentUser: UserProfile? // Lấy thông tin người dùng từ màn ProflieViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationbar()
        
        // Hiển thị placeholder thông tin của người dùng
        nameTF.text = currentUser?.name
        ageTF.text = "\(currentUser?.age ?? 0)"
        locationTF.text = currentUser?.location
        genderTF.text = currentUser?.gender
        
    }
    
    // Custom navigationbar
    func setUpNavigationbar(){
        // Hiển thị Navigationbar
        navigationController?.isNavigationBarHidden = false
        
        // Custom back navigation
        let backImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.backItem?.title = ""
        
        // Setup nút back
        navigationController?.navigationBar.tintColor = .black
        
        // custom nút Save
        saveBtn.layer.cornerRadius = saveBtn.frame.height / 2
    }
    
    @IBAction func saveEditHandle(_ sender: Any) {
        if let currentUser = currentUser{
            if let newName = nameTF.text,
               let newAge = Int(ageTF.text ?? ""),
               let newLocation = locationTF.text,
               let newGender = genderTF.text{
                let userRef = Database.database().reference().child("user").child(currentUser.userId)
                userRef.updateChildValues([
                    "name" : newName,
                    "age": newAge,
                    "location" : newLocation,
                    "gender": newGender
                ]) { (error, databseRef) in
                    if error != nil{
                        self.showAlert(withTitle: "Error", message: "Failure to update profile")
                    }else{
                        self.showAlert(withTitle: "Success", message: "Update profile successfully", completionHandler:{
                            self.navigationController?.popViewController(animated: true)
                        })
                       
                    }
                }
            }
        }
    }
    
    func showAlert(withTitle title: String, message: String, completionHandler: (()->Void)? = nil){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            completionHandler?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
