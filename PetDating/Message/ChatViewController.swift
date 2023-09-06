//
//  ChatViewController.swift
//  PetDating
//
//  Created by Trương Duy Tân on 17/08/2023.
//

import UIKit
import MessageKit
import FirebaseAuth
import FirebaseDatabase
import InputBarAccessoryView
import MessageInputBar

struct MockMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(text: String, sender: SenderType, messageId: String, date: Date) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.kind = .text(text)
    }
}

class ChatViewController: MessagesViewController {
    
    
    var messages: [MessageType] = []
    var matchId: String = ""
    let currentUser = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeMessages()
        navigationController?.isNavigationBarHidden = false
        setUpNavigation()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        // Reload dữ liệu để hiển thị tin nhắn
        messagesCollectionView.reloadData()
        print("❤️ \(matchId)")
    }
    
    func observeMessages() {
        guard let currentUser = currentUser, !matchId.isEmpty else {
            return
        }
        
        let databaseRef = Database.database().reference()
        
        // Sử dụng matchId để xác định đường dẫn đến tin nhắn của trận đấu này
        let messagesRef = databaseRef.child("matches").child(matchId).child("messages")
        
        // Lắng nghe sự thay đổi khi có bất kỳ thay đổi nào trong "messages"
        messagesRef.observe(.value) { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error observing messages: \(error)")
                return
            }
            
            if let messagesData = snapshot.value as? [String: [String: Any]] {
                // Xóa dữ liệu cũ trong mảng tin nhắn
                self.messages.removeAll()
                
                for (messageId, messageData) in messagesData {
                    if let senderId = messageData["sender"] as? String,
                       let text = messageData["content"] as? String,
                       let timestampString = messageData["timestamp"] as? String {
                        
                        // Thử chuyển đổi timestampString thành TimeInterval
                        if let sentDate = self.convertTimestampStringToTimeInterval(timestampString) {
                            let sender = Sender(senderId: senderId, displayName: senderId)
                            let message = MockMessage(text: text, sender: sender, messageId: messageId, date: sentDate)
                            
                            // Thêm tin nhắn vào mảng
                            self.messages.append(message)
                            print(sentDate)
                        } else {
                            // Xử lý lỗi nếu không thể chuyển đổi timestampString thành TimeInterval
                            print("Invalid timestamp format: \(timestampString)")
                        }
                    }
                }
                
                // Cập nhật giao diện sau khi đã lấy tất cả tin nhắn
                self.messages.sort(by: { $0.sentDate < $1.sentDate })
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    func sendMessage(_ messageText: String) {
        guard !messageText.isEmpty else {
            return
        }
        
        // Tạo một dictionary để biểu diễn tin nhắn mới
        let messageData: [String: Any] = [
            "sender": currentSender().senderId,
            "content": messageText,
            "timestamp": Date().iso8601String // Sử dụng một hàm mở rộng để chuyển đổi thời gian thành chuỗi định dạng ISO 8601
        ]
        
        let databaseRef = Database.database().reference()
        
        // Sử dụng matchId để xác định đường dẫn đến trận đấu cụ thể
        let matchMessagesRef = databaseRef.child("matches").child(matchId).child("messages")
        
        // Thêm tin nhắn vào cơ sở dữ liệu
        let newMessageRef = matchMessagesRef.childByAutoId()
        newMessageRef.setValue(messageData)
        
        // Tạo một đối tượng Message từ messageData và thêm nó vào mảng messages
        if let senderId = messageData["sender"] as? String,
           let text = messageData["content"] as? String,
           let timestampString = messageData["timestamp"] as? String,
           let sentDate = self.convertTimestampStringToTimeInterval(timestampString) {
            let sender = Sender(senderId: senderId, displayName: senderId)
            let message = MockMessage(text: text, sender: sender, messageId: newMessageRef.key ?? "", date: sentDate)
            
            self.messages.append(message)
            self.messages.sort(by: { $0.sentDate < $1.sentDate })
        }
        
        // Reload the messages collection view to display the new message
        self.messagesCollectionView.reloadData()
    }
    
    func convertTimestampStringToTimeInterval(_ timestampString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return dateFormatter.date(from: timestampString)
    }
    
    func setUpNavigation(){
        // Custom back navigation
        let backImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.backItem?.title = ""
    }
}

extension ChatViewController: MessagesDataSource{
    
    func currentSender() -> SenderType {
        if let currentUser = Auth.auth().currentUser?.uid {
            // Xác định người gửi tin nhắn
            if currentUser == self.currentUser {
                // Nếu là người dùng hiện tại, hiển thị bên phải
                return Sender(senderId: currentUser, displayName: "Your Display Name")
            } else {
                // Hiển thị bên trái cho người dùng được nhận
                return Sender(senderId: "otherUserId", displayName: "Other User's Display Name")
            }
        } else {
            return Sender(senderId: "unknown", displayName: "Unknown")
        }
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension ChatViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {
    
}

extension Date {
    var iso8601String: String {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.string(from: self)
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        // Xử lý việc gửi tin nhắn ở đây, ví dụ:
        sendMessage(text)
        inputBar.inputTextView.text = ""
        // Xóa nội dung trong trường nhập sau khi gửi
        
        print("🔴 Send button pressed with text: \(text)")
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        // Xử lý sự kiện thay đổi kích thước giao diện tại đây
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        // Xử lý sự kiện thay đổi nội dung của trường nhập tại đây
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
        // Xử lý sự kiện vuốt trường nhập tại đây (nếu cần)
    }
}
