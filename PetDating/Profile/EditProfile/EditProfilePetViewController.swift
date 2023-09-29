//
//  EditProfilePetViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 28/07/2023.
//

import UIKit
import FirebaseDatabase
import SCLAlertView

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
        nameTF.text = currentPetProfile?.name
        genderTF.text = currentPetProfile?.gender
        typeTF.text = currentPetProfile?.type
        ageTF.text = "\(currentPetProfile?.age ?? 0)"
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
                    if error != nil{
                        let appearance = SCLAlertView.SCLAppearance(
                            showCircularIcon: true
                        )
                        let alertView = SCLAlertView(appearance: appearance)
                        alertView.showError("Error", subTitle: "Failure to update pet's profile.")
                    }else{
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    func setUpNavigationbar(){
        // Hiển thị Navigationbar
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .black
        // Custom back navigation
        let backImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.backItem?.title = ""
        
        //setup nút Save
        saveBtn.layer.cornerRadius = saveBtn.frame.height/2
    }
}
