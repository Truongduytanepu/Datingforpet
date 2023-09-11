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

struct UserBot {
    var uid: String
    var name: String
    var image: String
}

class MessageViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    var users: [UserBot] = []
    var matchIds: [String] = []
    var topTableViewCell: TopTableViewCell?
    var databaseRef = Database.database().reference()
    let currentUser = Auth.auth().currentUser?.uid
    var userMatchIDs: [String] = []
    var receiverImageURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TopTableViewCell", bundle: nil), forCellReuseIdentifier: "TopTableViewCell")
        tableView.register(UINib(nibName: "BotTableViewCell", bundle: nil), forCellReuseIdentifier: "BotTableViewCell")
        tableView.separatorStyle = .none
        tableView.cellLayoutMarginsFollowReadableWidth = false
        navigationController?.isNavigationBarHidden = true
        fetchDataMatchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func fetchDataMatchUser() {
        let group = DispatchGroup() // Khởi tạo Dispatch Group

        userMatched { userMatched in
            if let userMatched = userMatched {
                self.userMatchIDs = userMatched
                self.databaseRef.child("matches").observeSingleEvent(of: .value) { snapshot,error  in
                    if let error = error {
                        print("Error fetching matches: \(error)")
                        return
                    }
                    if let matches = snapshot.value as? [String: [String: Any]] {
                        for (matchId, matchData) in matches {
                            if let participants = matchData["participants"] as? [String] {
                                // Kiểm tra xem cả currentUser và userMatched đều tồn tại trong participants
                                if participants.contains(self.currentUser ?? "") && participants.contains(where: { userMatched.contains($0) }) {
                                    self.matchIds.append(matchId)
                                    print("Common Participants:")
                                    for participant in participants {
                                        if participant == self.currentUser {
                                            continue
                                        } else {
                                            group.enter() // Bắt đầu một tác vụ mới trong Dispatch Group

                                            self.fetchUserBot(withUID: participant) { user in
                                                if let user = user {
                                                    DispatchQueue.main.async {
                                                        self.users.append(user)

                                                        // Khi dữ liệu của một người dùng đã được lấy, thoát khỏi Dispatch Group
                                                        group.leave()
                                                    }
                                                } else {
                                                    // Trong trường hợp xảy ra lỗi, cũng cần thoát khỏi Dispatch Group
                                                    group.leave()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Sử dụng Dispatch Group để đợi cho đến khi tất cả dữ liệu đã được lấy
                        group.notify(queue: .main) {
                            // Khi tất cả dữ liệu đã được lấy, cập nhật topTableViewCell và reloadData
                            self.topTableViewCell?.updateMatchIds(self.matchIds, currentUserID: self.currentUser)
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                print("Không có dữ liệu userMatched hoặc có lỗi.")
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
    
    public func fetchUserBot(withUID uid: String, completion: @escaping (UserBot?) -> Void) {
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
}

extension MessageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TopTableViewCell", for: indexPath) as! TopTableViewCell
            cell.matchedUsers = users
            cell.messageViewController = self
            topTableViewCell = cell
            return cell
        } else {
            if indexPath.row - 1 < users.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "BotTableViewCell", for: indexPath) as! BotTableViewCell
                let user = users[indexPath.row - 1]
                cell.configure(with: user)
                return cell
            } else {
                return UITableViewCell()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 170
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row > 0 && indexPath.row - 1 < matchIds.count {
            let selectedMatchId = matchIds[indexPath.row - 1]
            let storyboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            storyboard.matchId = selectedMatchId
            navigationController?.pushViewController(storyboard, animated: true)
        }
    }
}

