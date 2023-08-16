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
    let gender = ["Male", "Female", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        tableView.contentInsetAdjustmentBehavior = .never
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ẩn thanh điều hướng khi profileviewcontroller xuất hiện
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Hiển thị thanh điều hướng khi Profileviewcontriller biến mất
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
        return  1350
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath) as! ProfileTableViewCell
        
        // Kiểm tra xem đã có thông tin người dùng hiện tại hay chưa
        if let currentUser = currentUser {
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
            
            
            let imgView =  UIImageView(frame: self.tableView.frame)
            let img = UIImage(named: "backgroundprofile")
            imgView.image = img
            imgView.frame = CGRectMake(0, 0, self.tableView.frame.width, self.tableView.frame.height)
            imgView.contentMode = .scaleToFill
            cell.cellBackgroundView.addSubview(imgView)
            cell.cellBackgroundView.sendSubviewToBack(imgView)
//            tableView.layer.zPosition = 1
            tableView.backgroundColor = .clear
            
            
        }
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
        // Cập nhật giới tính đã chọn vào biến currentUser hoặc nơi bạn lưu trữ thông tin người dùng
        currentUser?.gender = selectedGender
        
        // Reload tableView để hiển thị giới tính đã chọn
        tableView.reloadData()
    }
}

extension ProfileViewController: ProfileTableViewCellDelegate{
    
    func editBtnTapped(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileOwnViewController") as! EditProfileOwnViewController
        editProfileVC.currentUser = self.currentUser
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
    
    func editBtnTappedPet(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editProfilePetVC = storyboard.instantiateViewController(withIdentifier: "EditProfilePetViewController") as! EditProfilePetViewController
        editProfilePetVC.currentPetProfile = self.currentUser?.pet
        editProfilePetVC.currentUser = self.currentUser
        navigationController?.pushViewController(editProfilePetVC, animated: true)
    }
}
