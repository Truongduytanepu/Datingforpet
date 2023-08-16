//
//  EditProfilePetViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 28/07/2023.
//

import UIKit
import FirebaseDatabase

class EditProfilePetViewController: UIViewController {

    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var typeTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    var currentPetProfile: PetProfile?
    var currentUser: UserProfile?// Lấy thông tin người dùng từ màn ProflieViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationbar()
        // Hiển thị thông tin placeholder của thú cưng
        nameTF.text = currentPetProfile?.name
        genderTF.text = currentPetProfile?.gender
        typeTF.text = currentPetProfile?.type
        ageTF.text = "\(currentPetProfile?.age ?? 0)"
    }
    func setUpNavigationbar(){
        // Hiển thị Navigationbar
        navigationController?.isNavigationBarHidden = false
        // Tạo title cho navigation
        let customTitle = UILabel()
        customTitle.text = "Edit Profile"
        customTitle.textColor = .black
        customTitle.font = UIFont.boldSystemFont(ofSize: 18)
        customTitle.textAlignment = .center
        
        // Đặt title cho navigationbar
        navigationItem.titleView = customTitle
        
        // Setup nút back
        navigationController?.navigationBar.tintColor = .black
        
        //setup nút Save
        saveBtn.layer.cornerRadius = saveBtn.frame.height/2
    }
    @IBAction func saveEditBtn(_ sender: Any) {
        if let currentUser = currentUser{
            if let newName = nameTF.text,
               let newAge = Int(ageTF.text ?? ""),
               let newGender = genderTF.text,
               let newType = typeTF.text{
                let userRef = Database.database().reference().child("user").child(currentUser.userId)
                userRef.child("pet").updateChildValues([
                    "name" : newName,
                    "age": newAge,
                    "gender" : newGender,
                    "type": newType
                ]) { (error, databseRef) in
                    if let error = error{
                        self.showAlert(withTitle: "Error", message: "Failure to update pet's profile")
                    }else{
                        self.showAlert(withTitle: "Success", message: "Update pet's profile successfully", completionHandler:{
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
