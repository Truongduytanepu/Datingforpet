//
//  SetProfilePetViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 08/08/2023.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Kingfisher
import SCLAlertView
import ActionSheetPicker_3_0

class SetProfilePetViewController: UIViewController {
    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var imagePet: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var typeTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var showGender: UIButton!
    let gender = ["Male", "Female", "Other"]
    var currentUser: UserProfile?
    private let storage = Storage.storage().reference()
    private var databaseRef = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePet.layer.cornerRadius = 15
        viewImage.layer.cornerRadius = 15
        saveBtn.layer.cornerRadius = saveBtn.frame.height / 2
    }
    
    @IBAction func editImage(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            // Người dùng đã đăng nhập, cho phép chọn ảnh
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true)
        } else {
            // Người dùng chưa đăng nhập, xử lí tương ứng
            let appearance = SCLAlertView.SCLAppearance(
                showCircularIcon: true
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.showError("Error", subTitle: "Please log in before selecting an image.")
            
        }
    }
    
    @IBAction func saveBtnHandle(_ sender: Any) {
        
        // Lưu thông tin người dùng vào cơ sở dữ liệu
        let newName = nameTF.text ?? ""
        let newAge = Int(ageTF.text ?? "") ?? 0
        let newtype = typeTF.text ?? ""
        let newGender = genderTF.text ?? ""
        
        let userData: [String: Any] = [
            "name": newName,
            "age": newAge,
            "type": newtype,
            "gender": newGender,
        ]
        let petRef = databaseRef.child("user").child(Auth.auth().currentUser?.uid ?? "").child("pet")
        petRef.updateChildValues(userData) { error, _ in
            if let error = error {
                let appearance = SCLAlertView.SCLAppearance(
                    showCircularIcon: true
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.showError("Error", subTitle: "Failure to save profile.")
            } else {
                UserDefaults.standard.set(true, forKey: "isSetProfilePet")
                AppDelegate.scene?.routeToMainController()
            }
        }
    }
    
    @IBAction func selectGenderBtn(_ sender: Any) {
        showGenderPicker(from: showGender)
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

    private func uploadPetImg(_ image: UIImage) {
        guard let imageData = image.pngData() else {
            return
        }
        
        let petImageRef = storage.child("pet_images/\(Auth.auth().currentUser?.uid ?? "")/pet_image.jpg")
        
        // Tải lên ảnh thú cưng
        petImageRef.putData(imageData, metadata: nil) { metadata, error in
            
            // Lấy URL tải về ảnh thú cưng
            petImageRef.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    print("Failed to get download URL")
                    return
                }
                
                // Lưu URL vào cơ sở dữ liệu
                self.databaseRef.child("user/\(Auth.auth().currentUser?.uid ?? "")/pet/img").setValue(downloadURL.absoluteString)
                
                // Cập nhật ảnh trong giao diện
                if let imageURL = URL(string: downloadURL.absoluteString) {
                    self.imagePet.kf.setImage(with: imageURL)
                }
            }
        }
    }
    
    
}

extension SetProfilePetViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        uploadPetImg(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

