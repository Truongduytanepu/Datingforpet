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

struct UserBot {
    var uid: String
    var name: String
    var image: String
    var lastMessageTimestamp: TimeInterval?

    // Initializer with lastMessageTimestamp parameter
    init(uid: String, name: String, image: String, lastMessageTimestamp: TimeInterval?) {
        self.uid = uid
        self.name = name
        self.image = image
        self.lastMessageTimestamp = lastMessageTimestamp
    }
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
    
    // Lấy dữ liệu và thông tin người dùng
    func fetchDataMatchUser() {
        let group = DispatchGroup()
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
                                if participants.contains(self?.currentUser ?? "") && participants.contains(where: { userMatched.contains($0) }) {
                                    self?.matchIds.append(matchId)
                                    for participant in participants {
                                        if participant == self?.currentUser {
                                            continue
                                        }

                                        group.enter()
                                        self?.fetchUserBot(withUID: participant, matchId: matchId) { user in
                                            if let user = user {
                                                DispatchQueue.main.async {
                                                    self?.users.append(user)
                                                    group.leave()
                                                }
                                            } else {
                                                group.leave()
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        group.notify(queue: .main) {
                            // Sort users based on lastMessageTimestamp in descending order
                            self?.users.sort(by: { $0.lastMessageTimestamp ?? 0 > $1.lastMessageTimestamp ?? 0 })
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

    
    // lấy danh sách matchids
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
    
    // Lấy thông tin người dùng bot từ firebase bằng uid
    func fetchUserBot(withUID uid: String, matchId: String, completion: @escaping (UserBot?) -> Void) {
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

                self.fetchLastMessageTimestamp(matchId: matchId) { timestamp in
                    let user = UserBot(uid: uid, name: userName, image: userImage, lastMessageTimestamp: timestamp)
                    completion(user)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchLastMessageTimestamp(matchId: String, completion: @escaping (TimeInterval?) -> Void) {
        let messagesRef = databaseRef.child("matches").child(matchId).child("messages")
        messagesRef.queryLimited(toLast: 1).observeSingleEvent(of: .value) { snapshot in
            if let messageData = snapshot.children.allObjects.first as? DataSnapshot,
               let messageTimestamp = messageData.childSnapshot(forPath: "timestamp").value as? TimeInterval {
                completion(messageTimestamp)
            } else {
                completion(nil)
            }
        }
    }

    
    // Lấy tin nhắn cuối cùng đẻ hiển thị lên giao diện
    func fetchLastMessageForMatch(matchId: String, completion: @escaping (String?) -> Void) {
        let messagesRef = databaseRef.child("matches").child(matchId).child("messages")
        
        messagesRef.queryLimited(toLast: 1).observe(.childAdded) { snapshot in
            
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
