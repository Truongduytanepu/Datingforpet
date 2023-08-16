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

class SetProfileUserViewController: UIViewController {
    
    @IBOutlet weak var viewImage: UIView!
    @IBOutlet weak var imageUser: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    var selectedImage: UIImage?
    private let storage = Storage.storage().reference()
    private var databaseRef: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        setUpUI()
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
            showAlert(withTitle: "Error", message: "Please log in before selecting an image.")
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
                "gender": newGender
            ]
            let userRef = databaseRef.child("user").child(currentUser.uid)
            userRef.updateChildValues(userData) { error, _ in
                if let error = error {
                    self.showAlert(withTitle: "Error", message: "Failure to save profile")
                } else {
                    self.showAlert(withTitle: "Success", message: "Save profile successfully") {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let setPetProfile = storyboard.instantiateViewController(withIdentifier: "SetProfilePetViewController") as! SetProfilePetViewController
                        self.navigationController?.pushViewController(setPetProfile, animated: true)
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
                
                // lưu URL xuống cơ sở dữ liệu
                print("Download URL: \(downloadURL)")
                
                // Cập nhật URL ảnh vào Realtime Database
                self.databaseRef.child("user/\(Auth.auth().currentUser?.uid ?? "")/image").setValue(downloadURL.absoluteString)
                
                // Cập nhật ảnh trong giao diện
                DispatchQueue.main.async {
                    self.imageUser.image = image
                }
            }
        }
    }
    
    func setUpUI(){
        imageUser.layer.cornerRadius = imageUser.frame.height / 2
        viewImage.layer.cornerRadius = viewImage.frame.height / 2
        saveBtn.layer.cornerRadius = saveBtn.frame.height / 2
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

