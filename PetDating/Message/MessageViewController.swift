//
//  MessageViewController.swift
//  FoodAppIOS
//
//  Created by Trương Duy Tân on 23/07/2023.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import MBProgressHUD
import SCLAlertView

protocol MessageDisplay{
    func showLoading(isShow: Bool)
}

struct UserBot {
    var uid: String
    var name: String
    var image: String
}

class MessageViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    var users: [UserBot] = []
    var matchIds: [String] = []
    var databaseRef = Database.database().reference()
    let currentUser = Auth.auth().currentUser?.uid
    var userMatchIDs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "BotTableViewCell", bundle: nil), forCellReuseIdentifier: "BotTableViewCell")
        tableView.separatorStyle = .none
        tableView.cellLayoutMarginsFollowReadableWidth = false
        fetchDataMatchUser()
        self.navigationItem.title = "Chat"
        if let navigationBar = self.navigationController?.navigationBar {
            let navigationTitleFont = UIFont.boldSystemFont(ofSize: 24.0)
            navigationBar.titleTextAttributes = [NSAttributedString.Key.font: navigationTitleFont]
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        showLoading(isShow: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLoading(isShow: false)
    }
    
    func fetchDataMatchUser() {
        let group = DispatchGroup() // Khởi tạo Dispatch Group
        showLoading(isShow: true)
        userMatched { userMatched in
            if let userMatched = userMatched {
                self.userMatchIDs = userMatched
                self.databaseRef.child("matches").observeSingleEvent(of: .value) { [weak self] snapshot, error in
                    if let error = error {
                        print("Error fetching matches: \(error)")
                        return
                    }
                    if let matches = snapshot.value as? [String: [String: Any]] {
                        for (matchId, matchData) in matches {
                            if let participants = matchData["participants"] as? [String] {
                                // Kiểm tra xem cả currentUser và userMatched đều tồn tại trong participants
                                if participants.contains(self?.currentUser ?? "") && participants.contains(where: { userMatched.contains($0) }) {
                                    // Thêm matchId vào danh sách
                                    self?.matchIds.append(matchId)
                                    // Lặp qua danh sách participants
                                    for participant in participants {
                                        if participant == self?.currentUser {
                                            continue // Bỏ qua người dùng đang đăng nhập hiện tại
                                        }
                                        
                                        // Lấy thông tin người dùng từ Firebase và thêm vào danh sách người dùng
                                        group.enter()
                                        self?.fetchUserBot(withUID: participant) { user in
                                            if let user = user {
                                                DispatchQueue.main.async {
                                                    self?.users.append(user)
                                                    // Khi dữ liệu của một người dùng đã được lấy, thoát khỏi Dispatch Group
                                                    group.leave()
                                                }
                                            } else {
                                                // Trong trường hợp xảy ra lỗi, thoát khỏi Dispatch Group
                                                group.leave()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Sử dụng Dispatch Group để đợi cho đến khi tất cả dữ liệu đã được lấy
                        group.notify(queue: .main) {
                            // Khi tất cả dữ liệu đã được lấy reloadData
                            self?.tableView.reloadData()
                            self?.showLoading(isShow: false)
                        }
                    }
                }
            } else {
                let appearance = SCLAlertView.SCLAppearance(
                    showCircularIcon: true
                )
                let alertView = SCLAlertView(appearance: appearance)
                alertView.showError("Error", subTitle: "UserMatched data does not exist or there is an error.")
                self.showLoading(isShow: false)
            }
        }
    }
    
    // Hàm để lấy danh sách userMatched
    func userMatched(completion: @escaping ([String]?) -> Void) {
        let databaseUserMatched = databaseRef.child("user").child(currentUser ?? "").child("matchIds")
        databaseUserMatched.observeSingleEvent(of: .value) { snapshot, error in
            
            if let userMatched = snapshot.value as? [String] {
                completion(userMatched)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchUserBot(withUID uid: String, completion: @escaping (UserBot?) -> Void) {
        let databaseUserRef = databaseRef.child("user").child(uid)
        databaseUserRef.observeSingleEvent(of: .value) { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error)")
                completion(nil)
                return
            }
            if let userData = snapshot.value as? [String: Any] {
                let userName = userData["name"] as? String ?? ""
                let userImage = userData["image"] as? String ?? ""
                
                let user = UserBot(uid: uid, name: userName, image: userImage)
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchLastMessageForMatch(matchId: String, completion: @escaping (String?) -> Void) {
        let messagesRef = databaseRef.child("matches").child(matchId).child("messages")
        
        messagesRef.queryLimited(toLast: 1).observe(.childAdded) { snapshot in
            print("🥲 \(snapshot)")
            
            if let messageData = snapshot.value as? [String: Any],
               let messageText = messageData["content"] as? String {
                completion(messageText)
            } else {
                completion(nil)
            }
        }
    }
}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BotTableViewCell", for: indexPath) as! BotTableViewCell
        let user = users[indexPath.row]
        cell.fetchLastMessage = { matchId, completion in
            self.fetchLastMessageForMatch(matchId: matchId, completion: completion)
        }
        cell.configure(with: user, matchId: matchIds[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < matchIds.count {
            let selectedMatchId = matchIds[indexPath.row]
            let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            storyboard.matchId = selectedMatchId
            navigationController?.pushViewController(storyboard, animated: true)
        }
    }
}

extension MessageViewController: MessageDisplay{
    func showLoading(isShow: Bool) {
        DispatchQueue.main.async {
            if isShow {
                MBProgressHUD.showAdded(to: self.view, animated: true)
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
}
