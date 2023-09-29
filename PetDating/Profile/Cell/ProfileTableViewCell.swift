//
//  ProfileTableViewCell.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 25/07/2023.
//

import UIKit
import ActionSheetPicker_3_0
import WARangeSlider
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Kingfisher
import SCLAlertView

// protocol để gửi dữ liệu từ cell về Vỉewcontroller
protocol ProfileTableViewCellDelegate: AnyObject {
    func editBtnTapped()
    func editBtnTappedPet()
    func sliderValueChange(lowerValue: Int, upperValue: Int)
    func showMeValueChange(selectedGender: String)
}

class ProfileTableViewCell: UITableViewCell, UIPickerViewDelegate,UIPickerViewDataSource {
    
    @IBOutlet weak var viewBtn1: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var discoveryLbl: UILabel!
    @IBOutlet weak var editPetImage: UIButton!
    @IBOutlet weak var editUserImage: UIButton!
    @IBOutlet weak var editBtn2: UIButton!
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var rangeSlider: RangeSlider!
    @IBOutlet weak var showGender: UIButton!
    @IBOutlet weak var viewImagePet: UIView!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var viewAgeShowMe: UIView!
    @IBOutlet weak var viewShowMe: UIView!
    @IBOutlet weak var viewAgePet: UIView!
    @IBOutlet weak var viewTypePet: UIView!
    @IBOutlet weak var viewGenderPet: UIView!
    @IBOutlet weak var viewNamePet: UIView!
    @IBOutlet weak var viewAge: UIView!
    @IBOutlet weak var viewLocation: UIView!
    @IBOutlet weak var viewGender: UIView!
    @IBOutlet weak var viewImageOwn: UIView!
    @IBOutlet weak var imageOwn: UIImageView!
    @IBOutlet weak var logOut: UIButton!
    @IBOutlet weak var resultSlider: UILabel!
    @IBOutlet weak var agePet: UILabel!
    @IBOutlet weak var typePet: UILabel!
    @IBOutlet weak var genderPet: UILabel!
    @IBOutlet weak var namePet: UILabel!
    @IBOutlet weak var imagePet: UIImageView!
    @IBOutlet weak var ageOwn: UILabel!
    @IBOutlet weak var locationOwn: UILabel!
    @IBOutlet weak var genderOwn: UILabel!
    @IBOutlet weak var nameOwn: UILabel!
    @IBOutlet weak var editBtn1: UIButton!
    @IBOutlet weak var nameAndAgeOwn: UILabel!
    
    var genderPickerView: UIPickerView!
    var gender: [String]!
    var currentUser: UserProfile?
    var delegate: ProfileTableViewCellDelegate?
    var isAddingUserImage = false
    var isAddingPetImage = false
    
    private var userImagePicker: UIImagePickerController = UIImagePickerController()
    private var petImagePicker:UIImagePickerController = UIImagePickerController()
    private let storage = Storage.storage().reference()
    private var databaseRef: DatabaseReference!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpUI()
        // Cài đặt giá trị cho slider
        rangeSlider.minimumValue = 0
        rangeSlider.maximumValue = 50
        rangeSlider.lowerValue = 20
        rangeSlider.upperValue = 30
        updateResultLabel(lowerValue: rangeSlider.lowerValue, upperValue: rangeSlider.upperValue)
        rangeSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        databaseRef = Database.database().reference()
        setupImagePickers()
        
        // Lấy giá trị slider trong firebase
        if let currentUser = Auth.auth().currentUser {
            databaseRef.child("user/\(currentUser.uid)/sliderValue").observeSingleEvent(of: .value) { snapshot in
                if let sliderValues = snapshot.value as? [String: Int],
                   let lowerValue = sliderValues["lower"],
                   let upperValue = sliderValues["upper"] {
                    self.rangeSlider.lowerValue = Double(lowerValue)
                    self.rangeSlider.upperValue = Double(upperValue)
                    self.updateResultLabel(lowerValue: Double(lowerValue), upperValue: Double(upperValue))
                }
            }
        }
        
        // Lấy giới tính từ firebase
        if let currentUser = Auth.auth().currentUser{
            databaseRef.child("user/\(currentUser.uid)/showMe").observeSingleEvent(of: .value){ snapshot in
                if let selectedGender = snapshot.value as? String{
                    self.showGender.setTitle(selectedGender, for: .normal)
                }
            }
        }
    }
    
    // Khởi tạo picker cho việc chọn ảnh
    private func setupImagePickers() {
        userImagePicker.delegate = self
        userImagePicker.sourceType = .photoLibrary
        userImagePicker.allowsEditing = false
        
        petImagePicker.delegate = self
        petImagePicker.sourceType = .photoLibrary
        petImagePicker.allowsEditing = false
    }
    
    // Cập nhật giá trị slider với giá trị ban đầu
    func updateResultLabel(lowerValue: Double, upperValue: Double) {
        resultSlider.text = "\(Int(lowerValue)) - \(Int(upperValue))"
    }
    
    // Gán giá trị của slider vào text Result
    @objc func sliderValueChanged(_ slider: RangeSlider) {
        let lowerValue = Int(slider.lowerValue)
        let upperValue = Int(slider.upperValue)
        resultSlider.text = "\(lowerValue) - \(upperValue)"
        
        // Cập nhật giá trị slider vào Firebase
        if let currentUser = Auth.auth().currentUser {
            databaseRef.child("user/\(currentUser.uid)/sliderValue").setValue(["lower": lowerValue, "upper": upperValue])
            self.delegate?.sliderValueChange(lowerValue: lowerValue, upperValue: upperValue)
        }
    }
    
    // Đăng xuất và chuyển đến màn hình đăng nhập
    @IBAction func logOutBtnHandle(_ sender: Any) {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            
            // Xoá thông tin đăng nhập lưu trữ bằng UserDefaults
            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            
            // Thiết lập lại giá trị isLoggedIn thành false
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                let navigationController = UINavigationController(rootViewController: loginVC)
                navigationController.isNavigationBarHidden = true
                appDelegate.window?.rootViewController = navigationController
                appDelegate.window?.makeKeyAndVisible()
            }
        }catch{
            let appearance = SCLAlertView.SCLAppearance(
                showCircularIcon: true
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.showError("Error", subTitle: "Logout Failure.")
        }
    }
    
    // Chỉnh sửa ảnh thú cưng
    @IBAction func editImagePet(_ sender: Any) {
        isAddingPetImage = true
        isAddingUserImage = false
        self.window?.rootViewController?.present(petImagePicker, animated: true, completion: nil)
    }
    
    // Chỉnh sửa ảnh người dùng
    @IBAction func editImageUser(_ sender: Any) {
        isAddingPetImage = false
        isAddingUserImage = true
        self.window?.rootViewController?.present(userImagePicker, animated: true, completion: nil)
    }
    
    @IBAction func editBtnHandle(_ sender: Any) {
        delegate?.editBtnTapped()
    }
    
    @IBAction func editBtnPetHandle(_ sender: Any) {
        delegate?.editBtnTappedPet()
    }
    
    @IBAction func selectGenderBtn(_ sender: Any) {
        showGenderPicker()
    }
    
    private func uploadUserImage(_ image: UIImage) {
        guard let imageData = image.pngData() else {
            return
        }
        
        storage.child("user_images/\(Auth.auth().currentUser?.uid ?? "")/user_image.jpg").putData(imageData, metadata: nil) { _, error in
            guard error == nil else {
                let appearance = SCLAlertView.SCLAppearance(
                    showCircularIcon: true
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.showError("Error", subTitle: "Failure to upload")
                return
            }
            
            self.storage.child("user_images/\(Auth.auth().currentUser?.uid ?? "")/user_image.jpg").downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    print("Failed to get download URL")
                    return
                }
                
                // Cập nhật URL ảnh vào firebase
                self.databaseRef.child("user/\(Auth.auth().currentUser?.uid ?? "")/image").setValue(downloadURL.absoluteString)
                
                // Cập nhật ảnh trong giao diện
                DispatchQueue.main.async {
                    self.imageOwn.image = image
                }
            }
        }
    }
    
    private func uploadPetImage(_ image: UIImage) {
        guard let imageData = image.pngData() else {
            return
        }
        
        let petImageRef = storage.child("pet_images/\(Auth.auth().currentUser?.uid ?? "")/pet_image.jpg")
        
        // Tải lên ảnh thú cưng
        petImageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                let appearance = SCLAlertView.SCLAppearance(
                    showCircularIcon: true
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.showError("Error", subTitle: error.localizedDescription)
                return
            }
            
            // Lấy URL tải về ảnh thú cưng
            petImageRef.downloadURL { url, error in
                guard let downloadURL = url, error == nil else {
                    let appearance = SCLAlertView.SCLAppearance(
                        showCircularIcon: true
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.showError("Error", subTitle: error?.localizedDescription ?? "Failed to get download URL.")
                    return
                }
                
                // Lưu URL vào cơ sở dữ liệu
                self.databaseRef.child("user/\(Auth.auth().currentUser?.uid ?? "")/pet/img").setValue(downloadURL.absoluteString)
                
                // Cập nhật ảnh trong giao diện
                DispatchQueue.main.async {
                    self.imagePet.image = image
                }
            }
        }
    }
    
    func setUpUI(){
        let attributedText = NSAttributedString(string: "Edit", attributes: [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        imageOwn.layer.cornerRadius = imageOwn.frame.height / 2
        viewImageOwn.layer.cornerRadius = viewImageOwn.frame.height / 2
        imagePet.layer.cornerRadius = 10
        logOut.layer.borderWidth = 1.0
        logOut.layer.cornerRadius = logOut.frame.height / 2
        logOut.layer.borderColor = UIColor(red: 0.766, green: 0.766, blue: 0.766, alpha: 1).cgColor
        viewImagePet.layer.cornerRadius = 30
        editBtn1.setAttributedTitle(attributedText, for: .normal)
        editBtn2.setAttributedTitle(attributedText, for: .normal)
        viewAge.setUpView()
        viewName.setUpView()
        viewGender.setUpView()
        viewLocation.setUpView()
        viewNamePet.setUpView()
        viewGenderPet.setUpView()
        viewTypePet.setUpView()
        viewAgePet.setUpView()
        viewShowMe.setUpView()
        viewAgeShowMe.setUpView()
        viewBtn1.layer.cornerRadius = viewBtn1.frame.height / 2
        viewBtn1.backgroundColor = UIColor(red: 250/255, green: 86/255, blue: 114/255, alpha: 1.0)
        resultSlider.tintColor = UIColor(red: 250/255, green: 86/255, blue: 114/255, alpha: 1.0)
    }
    
    // Sử dụng ActionSheetStringPicker để hiển thị UIPickerView
    func showGenderPicker() {
        ActionSheetStringPicker.show(withTitle: "Select Gender", rows: gender, initialSelection: 0, doneBlock: { [weak self] picker, selectedIndex, selectedValue in
            guard let selectedGender = selectedValue as? String else { return }
            self?.currentUser?.gender = selectedGender
            self?.showGender.setTitle(selectedGender, for: .normal)
            
            if let currentUser = Auth.auth().currentUser{
                self?.databaseRef.child("user/\(currentUser.uid)/showMe").setValue(selectedGender)
                self?.delegate?.showMeValueChange(selectedGender: selectedGender)
            }
        }, cancel: nil, origin: self)
    }
    
    func hideView(){
        editBtn1.isHidden = true
        editBtn2.isHidden = true
        editUserImage.isHidden = true
        editPetImage.isHidden = true
        discoveryLbl.isHidden = true
        viewShowMe.isHidden = true
        viewAgeShowMe.isHidden = true
        view.isHidden = true
        logOut.isHidden = true
        viewBtn1.isHidden = true
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension UIView {
    
    func setUpView() {
        self.layer.borderColor = UIColor(red: 0.766, green: 0.766, blue: 0.766, alpha: 1).cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5
    }
}

extension ProfileTableViewCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        // Kiểm tra nguồn ảnh và tải lên
        if picker == userImagePicker {
            uploadUserImage(image)
        }
        if picker == petImagePicker {
            uploadPetImage(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true, completion: nil)
    }
}
