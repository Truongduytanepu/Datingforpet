//
//  SetProfileUserViewController.swift
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

class SetProfileUserViewController: UIViewController {
    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var showGender: UIButton!
    @IBOutlet weak var nameTF: UITextField!
    let gender = ["Male", "Female", "Other"]
    var selectedImage: UIImage?
    private let storage = Storage.storage().reference()
    private var databaseRef = Database.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageUser.layer.cornerRadius = imageUser.frame.height / 2
        viewImage.layer.cornerRadius = viewImage.frame.height / 2
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
        if let currentUser = Auth.auth().currentUser {
            
            // Kiểm tra xem người dùng đã chọn ảnh chưa
            if selectedImage != nil {
                // Tải ảnh lên và lưu URL vào cơ sở dữ liệu
                uploadUserImg(selectedImage!)
            }
            
            // Lưu thông tin người dùng vào cơ sở dữ liệu
            let newName = nameTF.text ?? ""
            let newAge = Int(ageTF.text ?? "") ?? 0
            let newLocation = locationTF.text ?? ""
            let newGender = genderTF.text ?? ""
            
            let userData: [String: Any] = [
                "name": newName,
                "age": newAge,
                "location": newLocation,
                "gender": newGender,
                "sliderValue": [
                    "upper": 20,
                    "lower": 0
                ],
                "showMe": "Male"
            ]
            let userRef = databaseRef.child("user").child(currentUser.uid)
            userRef.updateChildValues(userData) { error, _ in
                if let error = error {
                    let appearance = SCLAlertView.SCLAppearance(
                        showCircularIcon: true
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.showError("Error", subTitle: "Failure to save profile.")
                } else {
                    UserDefaults.standard.set(true, forKey: "isSetProfileUser")
                    AppDelegate.scene?.routeToPetProfile()
                }
            }
        }
    }
    
    @IBAction func selectGender(_ sender: Any) {
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
    
    private func uploadUserImg(_ image: UIImage) {
        guard let imageData = image.pngData() else {
            return
        }
        
        storage.child("user_images/\(Auth.auth().currentUser?.uid ?? "")/user_image.jpg").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                print("Failure to upload")
                return
            }
            
            self.storage.child("user_images/\(Auth.auth().currentUser?.uid ?? "")/user_image.jpg").downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    print("Failed to get download URL")
                    return
                }
                
                // Cập nhật URL ảnh vào Realtime Database
                self.databaseRef.child("user/\(Auth.auth().currentUser?.uid ?? "")/image").setValue(downloadURL.absoluteString)
                
                // Cập nhật ảnh trong giao diện
                if let imageURL = URL(string: downloadURL.absoluteString) {
                    self.imageUser.kf.setImage(with: imageURL)
                }
            }
        }
    }
}

extension SetProfileUserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        uploadUserImg(image)
        picker.dismiss(animated: true, completion: nil)
    }
}

func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
}

