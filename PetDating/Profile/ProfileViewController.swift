//
//  ProfileViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 10/07/2023.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import MBProgressHUD

struct UserProfile {
    let userId: String
    let name: String
    let age: Int
    let location: String
    var gender: String
    let image: String
    let pet: PetProfile
}

struct PetProfile {
    let name: String
    let type: String
    let age: Int
    let gender: String
    let img: String
}

class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var currentUser: UserProfile?
    var currentPet: PetProfile?
    var user: User?
    let gender = ["Male", "Female", "Other"]
    var isHideView = false
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoading(isShow: true)
        setupTableView()
        tableView.contentInsetAdjustmentBehavior = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        showLoading(isShow: true)
        if let _ = user {
            fetchUserProfile()
        } else {
            fetchUser()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showLoading(isShow: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Hiển thị thanh điều hướng khi Profileviewcontriller biến mất
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setUpNavigation(){
        // Custom back navigation
        let backImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.backItem?.title = ""
        navigationController?.navigationBar.tintColor = .black
    }
    
    
    func fetchUserProfile() {
        if let user = user {
            currentUser = UserProfile(userId: user.userId, name: user.name, age: user.age, location: user.location, gender: user.gender ?? "", image: user.image ?? "", pet: PetProfile(name: user.pet?.name ?? "", type: user.pet?.type ?? "", age: user.pet?.age ?? 0, gender: user.pet?.gender ?? "", img: user.pet?.image ?? ""))
        }
    }
    
    func fetchUser(){
        showLoading(isShow: true)
        // Kiểm tra xem người dùng đã đăng nhập hay chưa
        if let currentUser = Auth.auth().currentUser?.uid {
            let userRef = Database.database().reference().child("user").child(currentUser)
            userRef.observeSingleEvent(of: .value, with: { snapshot in
                if let userData = snapshot.value as? [String: Any] {
                    let name = userData["name"] as? String ?? ""
                    let age = userData["age"] as? Int ?? 0
                    let location = userData["location"] as? String ?? ""
                    let gender = userData["gender"] as? String ?? ""
                    let userImageUrl = userData["image"] as? String ?? ""
                    
                    // Lấy thông tin của pet từ Firebase
                    if let petData = userData["pet"] as? [String: Any] {
                        let petName = petData["name"] as? String ?? ""
                        let petType = petData["type"] as? String ?? ""
                        let petAge = petData["age"] as? Int ?? 0
                        let petGender = petData["gender"] as? String ?? ""
                        let petImageUrl = petData["img"] as? String ?? ""
                        
                        // Lưu thông tin của pet vào biến currentUser
                        self.currentUser = UserProfile(userId: currentUser, name: name, age: age, location: location, gender: gender, image: userImageUrl, pet: PetProfile(name: petName, type: petType, age: petAge, gender: petGender, img: petImageUrl))
                    }
                    
                    // Hiển thị thông tin người dùng lên giao diện
                    self.tableView.reloadData()
                }
                
            }) { error in
                print("Failed to fetch user data:", error)
            }
        }
        showLoading(isShow: false)
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileTableViewCell")
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let currentUserID = Auth.auth().currentUser?.uid, currentUser?.userId != currentUserID {
            navigationController?.setNavigationBarHidden(false, animated: true)
            setUpNavigation()
            return 1400
        }else{
            navigationController?.setNavigationBarHidden(true, animated: true)
            return 1720
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
        // Kiểm tra xem đã có thông tin người dùng hiện tại hay chưa
        if let currentUser = currentUser {
            if let currentUserID = Auth.auth().currentUser?.uid, currentUser.userId != currentUserID {
                cell.hideView()
            }
            // Hiển thị thông tin người dùng lên cell
            cell.nameOwn.text = currentUser.name
            cell.ageOwn.text = String(currentUser.age )
            cell.locationOwn.text = currentUser.location
            cell.genderOwn.text = currentUser.gender
            cell.nameAndAgeOwn.text = "\(currentUser.name), \(currentUser.age)"
            
            // Sử dụng Kingfisher để tải ảnh người dùng từ URL
            if let imageURL = URL(string: currentUser.image) {
                cell.imageOwn.kf.setImage(with: imageURL)
            }
            cell.namePet.text = currentUser.pet.name
            cell.agePet.text = String(currentUser.pet.age)
            cell.genderPet.text = currentUser.pet.gender
            cell.typePet.text = currentUser.pet.type
            
            // Sử dụng Kingfisher để tải ảnh pet dùng từ URL
            if let imagePetURL = URL(string: currentUser.pet.img) {
                cell.imagePet.kf.setImage(with: imagePetURL)
            }
            
            cell.gender = gender
            cell.delegate = self
            
            // Thiết lập background cho profile
            let imgView =  UIImageView(frame: self.tableView.frame)
            let img = UIImage(named: "backgroundprofile")
            imgView.image = img
            imgView.frame = CGRectMake(0, 0, self.tableView.frame.width, self.tableView.frame.height)
            imgView.contentMode = .scaleToFill
            cell.cellBackgroundView.addSubview(imgView)
            cell.cellBackgroundView.sendSubviewToBack(imgView)
            tableView.backgroundColor = .clear
        }
        showLoading(isShow: false)
        return cell
    }
}

extension ProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedGender = gender[row]
        // Cập nhật giới tính đã chọn vào biến currentUser
        currentUser?.gender = selectedGender
        
        // Reload tableView để hiển thị giới tính đã chọn
        tableView.reloadData()
    }
}

extension ProfileViewController: ProfileTableViewCellDelegate{
    
    func showMeValueChange(selectedGender: String) {
        tableView.reloadData()
    }
    
    func sliderValueChange(lowerValue: Int, upperValue: Int) {
        tableView.reloadData()
    }
    
    // Chuyển đến màn EditProfileOwnViewController
    func editBtnTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileOwnViewController") as! EditProfileOwnViewController
        editProfileVC.currentUser = self.currentUser
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    // Chuyển đến màn EditProfilePetViewController
    func editBtnTappedPet(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editProfilePetVC = storyboard.instantiateViewController(withIdentifier: "EditProfilePetViewController") as! EditProfilePetViewController
        editProfilePetVC.currentPetProfile = self.currentUser?.pet
        editProfilePetVC.currentUser = self.currentUser
        navigationController?.pushViewController(editProfilePetVC, animated: true)
    }
}
