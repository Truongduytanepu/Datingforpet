//
//  EditProfileOwnViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 26/07/2023.
//

import UIKit
import FirebaseDatabase
import SCLAlertView
import ActionSheetPicker_3_0

class EditProfileOwnViewController: UIViewController {
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var genderTF: UITextField!
    let gender = ["Male", "Female", "Other"]
    var currentUser: UserProfile? // Lấy thông tin người dùng từ màn ProflieViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationbar()
        nameTF.text = currentUser?.name
        ageTF.text = "\(currentUser?.age ?? 0)"
        locationTF.text = currentUser?.location
        genderTF.text = currentUser?.gender
        
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
    
    @IBAction func selectGender(_ sender: Any) {
        showGenderPicker(from: genderBtn)
    }
    
    func showGenderPicker(from originView: UIView) {
        ActionSheetStringPicker.show(
            withTitle: "Select Gender",
            rows: gender,
            initialSelection: 0,
            doneBlock: { [weak self] picker, selectedIndex, selectedValue in
                guard let selectedGender = selectedValue as? String else { return }
                self?.genderTF.text = selectedGender
            },
            cancel: nil,
            origin: originView
        )
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
}
