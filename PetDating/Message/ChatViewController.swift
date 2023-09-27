import UIKit
import MessageKit
import FirebaseAuth
import FirebaseDatabase
import InputBarAccessoryView
import MessageInputBar
import Kingfisher

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
    var selectedUser: UserBot?
    var matchId: String = ""
    let currentUser = Auth.auth().currentUser?.uid
    var receiverImageURL: String = ""
    var pinkColor = UIColor(red: 250/255, green: 86/255, blue: 114/255, alpha: 1.0)
    var greyColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
    let databaseRef = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeMessages()
        navigationController?.isNavigationBarHidden = false
        setUpNavigation()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.setTitleColor(UIColor(red: 250/255, green: 86/255, blue: 114/255, alpha: 1.0), for: .normal)
        messagesCollectionView.reloadData()
    }
    
    // lắng nghe tin nhắn từ firebase
    func observeMessages() {
        guard let currentUser = currentUser, !matchId.isEmpty else {
            return
        }
        
        let databaseRef = Database.database().reference()
        let messagesRef = databaseRef.child("matches").child(matchId).child("messages")
        
        messagesRef.observe(.value) { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error observing messages: \(error)")
                return
            }
            
            if let messagesData = snapshot.value as? [String: [String: Any]] {
                self.messages.removeAll()
                
                for (messageId, messageData) in messagesData {
                    if let senderId = messageData["sender"] as? String,
                       let text = messageData["content"] as? String,
                       let timestampString = messageData["timestamp"] as? String {
                        
                        if let sentDate = self.convertTimestampStringToTimeInterval(timestampString) {
                            let sender = Sender(senderId: senderId, displayName: senderId)
                            let message = MockMessage(text: text, sender: sender, messageId: messageId, date: sentDate)
                            
                            self.messages.append(message)
                            print(sentDate)
                        } else {
                            print("Invalid timestamp format: \(timestampString)")
                        }
                    }
                }
                
                self.messages.sort(by: { $0.sentDate < $1.sentDate })
                self.messagesCollectionView.reloadData()
            }
        }
    }
    
    func sendMessage(_ messageText: String) {
        guard !messageText.isEmpty else {
            return
        }
        
        let messageData: [String: Any] = [
            "sender": currentSender().senderId,
            "content": messageText,
            "timestamp": Date().iso8601String // chuyển đổi thời gian thành chuỗi định dạng ISO 8601
        ]
        
        // thêm tin nhắn vào firebase
        let matchMessagesRef = databaseRef.child("matches").child(matchId).child("messages")
        let newMessageRef = matchMessagesRef.childByAutoId()
        newMessageRef.setValue(messageData)
        
        //Tạo một đối tượng Message từ messageData và thêm nó vào mảng messages
        if let senderId = messageData["sender"] as? String,
           let text = messageData["content"] as? String,
           let timestampString = messageData["timestamp"] as? String,
           let sentDate = self.convertTimestampStringToTimeInterval(timestampString) {
            let sender = Sender(senderId: senderId, displayName: senderId)
            let message = MockMessage(text: text, sender: sender, messageId: newMessageRef.key ?? "", date: sentDate)
            
            self.messages.append(message)
            self.messages.sort(by: { $0.sentDate < $1.sentDate })
        }
        
        self.messagesCollectionView.reloadData()
    }
    
    // chuyển đổi chuỗi thời gian thành kiểu Date
    func convertTimestampStringToTimeInterval(_ timestampString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return dateFormatter.date(from: timestampString)
    }
    
    func setUpNavigation(){
        let backImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.backItem?.title = ""
        navigationController?.navigationBar.tintColor = .black
    }
}

extension ChatViewController: MessagesDataSource{
    func currentSender() -> SenderType {
        if let currentUser = Auth.auth().currentUser?.uid {
            if currentUser == self.currentUser {
                return Sender(senderId: currentUser, displayName: "")
            } else {
                return Sender(senderId: "", displayName: "")
            }
        } else {
            return Sender(senderId: "", displayName: "")
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
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? pinkColor : greyColor
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize.zero
    }
    
    func messageContainerSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 250, height: 50)
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .black
    }
}

extension Date {
    var iso8601String: String {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.string(from: self)
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate{
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        sendMessage(text)
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
    }
}
