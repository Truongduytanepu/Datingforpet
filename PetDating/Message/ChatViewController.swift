import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher
import MessageKit
import InputBarAccessoryView
import FirebaseStorage

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct MockMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var type: String

    init(text: String, sender: SenderType, messageId: String, date: Date) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.kind = .text(text)
        self.type = "text"
    }

    init(imageURL: URL, sender: SenderType, messageId: String, date: Date) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
        self.type = "image"

        let mediaItem = Media(url: imageURL, image: nil, placeholderImage: UIImage(), size: CGSize(width: 200, height: 200))
        self.kind = .photo(mediaItem)
    }
}

class ChatViewController: MessagesViewController {
    var messages: [MessageType] = []
    var selectedUser: UserBot?
    var matchId: String = ""
    let currentUser = Auth.auth().currentUser?.uid
    var pinkColor = UIColor(red: 250/255, green: 86/255, blue: 114/255, alpha: 1.0)
    var greyColor = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1.0)
    let databaseRef = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        observeMessages()
        navigationController?.isNavigationBarHidden = false
        setUpNavigation()
        self.title = ""
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.setTitleColor(UIColor(red: 250/255, green: 86/255, blue: 114/255, alpha: 1.0), for: .normal)
        messagesCollectionView.reloadData()

        let cameraItem = makeButton(named: "ic_camera")
        cameraItem.addTarget(self, action: #selector(didPressCameraButton), for: .primaryActionTriggered)
        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: true)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.incomingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.attributedTextMessageSizeCalculator.avatarLeadingTrailingPadding = .zero
        }
        
        
    }

    private func makeButton(named _: String) -> InputBarButtonItem {
        InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(systemName: "camera.fill")?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }.onSelected {
                $0.tintColor = .systemBlue
            }.onDeselected {
                $0.tintColor = UIColor.lightGray
            }.onTouchUpInside { _ in
                print("Item Tapped")
            }
    }

    @objc func didPressCameraButton() {
        presentImagePicker()
    }
    
    func scrollToLastItem() {
            if !messages.isEmpty {
                let lastSection = messagesCollectionView.numberOfSections - 1
                let lastItem = messagesCollectionView.numberOfItems(inSection: lastSection) - 1
                let lastIndexPath = IndexPath(item: lastItem, section: lastSection)
                messagesCollectionView.scrollToItem(at: lastIndexPath, at: .bottom, animated: false)
            }
        }

    func observeMessages() {
        guard let _ = currentUser, !matchId.isEmpty else {
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
                // Tạo một mảng mới chứa tin nhắn mới từ Firebase
                let newMessages = messagesData.compactMap { (messageId, messageData) -> MockMessage? in
                    guard let senderId = messageData["sender"] as? String,
                          let text = messageData["content"] as? String,
                          let timestampString = messageData["timestamp"] as? String,
                          let type = messageData["type"] as? String,
                          let sentDate = self.convertTimestampStringToTimeInterval(timestampString) else {
                        return nil
                    }

                    let sender = Sender(senderId: senderId, displayName: senderId)

                    switch type {
                    case "text":
                        return MockMessage(text: text, sender: sender, messageId: messageId, date: sentDate)

                    case "image":
                        if let imageURLString = messageData["content"] as? String,
                           let imageURL = URL(string: imageURLString) {
                            return MockMessage(imageURL: imageURL, sender: sender, messageId: messageId, date: sentDate)
                        }

                    default:
                        break
                    }

                    return nil
                }

                // Cập nhật mảng self.messages với tin nhắn mới
                for newMessage in newMessages {
                    if let index = self.messages.firstIndex(where: { $0.messageId == newMessage.messageId }) {
                        // Tin nhắn đã tồn tại, cập nhật nó
                        self.messages[index] = newMessage
                    } else {
                        // Tin nhắn chưa tồn tại, thêm vào mảng
                        self.messages.append(newMessage)
                    }
                }

                // Sắp xếp mảng theo thời gian và cập nhật giao diện
                self.messages.sort(by: { $0.sentDate < $1.sentDate })
                self.messagesCollectionView.reloadData()
                self.scrollToLastItem()
            }
        }
    }

    
    func sendMessage(_ messageText: String, type: String) {
        guard !messageText.isEmpty else {
            return
        }

        var messageData: [String: Any] = [
            "sender": currentSender().senderId,
            "content": messageText,
            "timestamp": Date().ISO8601Format(),
            "type": type
        ]

        if type == "image" {
            messageData["content"] = ""
        }

        let matchMessagesRef = databaseRef.child("matches").child(matchId).child("messages")
        let newMessageRef = matchMessagesRef.childByAutoId()
            newMessageRef.setValue(messageData)

           
            if let senderId = messageData["sender"] as? String,
               let text = messageData["content"] as? String,
               let timestampString = messageData["timestamp"] as? String,
               let type = messageData["type"] as? String {
                let sender = Sender(senderId: senderId, displayName: senderId)

                switch type {
                case "text":
                    if let sentDate = self.convertTimestampStringToTimeInterval(timestampString) {
                        let message = MockMessage(text: text, sender: sender, messageId: newMessageRef.key ?? "", date: sentDate)
                        self.messages.append(message)
                        self.messages.sort(by: { $0.sentDate < $1.sentDate })
                        self.messagesCollectionView.reloadData()
                    } else {
                        print("Invalid timestamp format: \(timestampString)")
                    }

                case "image":
                   break

                default:
                    break
                }
        }
    }

    func convertTimestampStringToTimeInterval(_ timestampString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: timestampString)
    }

    func setUpNavigation() {
        let backImage = UIImage(named: "back")
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        self.navigationController?.navigationBar.backItem?.title = ""
        navigationController?.navigationBar.tintColor = .black
    }
}

extension ChatViewController: MessagesDataSource {
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

    // Thêm phương thức này để cung cấp media item cho tin nhắn kiểu ảnh
    func mediaItem(for message: MessageType) -> MediaItem? {
        switch message.kind {
        case .photo(let media):
            return media
        default:
            return nil
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? pinkColor : greyColor
    }

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .black
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }

    // Điều chỉnh cách hiển thị tin nhắn ảnh
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .photo(let media):
            if let imageURL = media.url {
                imageView.kf.setImage(with: imageURL)
            } else {
                imageView.image = UIImage(named: "placeholder_image")
            }
        default:
            break
        }
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy h:mm a"

        let sentDate = message.sentDate
        let dateString = dateFormatter.string(from: sentDate)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]

        return NSAttributedString(string: dateString, attributes: attributes)
    }

}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let isImage =  false

        sendMessage(text, type: isImage ? "image" : "text")
        messageInputBar.inputTextView.text = String()
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {}

    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {}

    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {}
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)

        let libraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }

        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                print("Camera not available on this device")
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(libraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func showCameraNotAvailableAlert() {
        let alertController = UIAlertController(title: "Camera Not Available", message: "Your device doesn't support camera functionality.", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let selectedImage = info[.originalImage] as? UIImage {
            sendImageMessage(photo: selectedImage)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func sendImageMessage(photo: UIImage) {
        guard let currentUser = Auth.auth().currentUser else {
            return
        }

        let messageData: [String: Any] = [
            "sender": currentUser.uid,
            "timestamp": Date().ISO8601Format(),
            "type": "image"
        ]

        let matchMessagesRef = databaseRef.child("matches").child(matchId).child("messages")
        let newMessageRef = matchMessagesRef.childByAutoId()
        newMessageRef.setValue(messageData)

        let storageRef = Storage.storage().reference().child("message_images").child(newMessageRef.key ?? "")
        let imageData = photo.jpegData(compressionQuality: 0.8)

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        storageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            guard error == nil else {
               

                print("Error uploading image: \(error!.localizedDescription)")
                return
            }

            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Error getting download URL: \(error!.localizedDescription)")
                    return
                }

                newMessageRef.updateChildValues(["content": downloadURL.absoluteString])

                
                if let senderId = messageData["sender"] as? String,
                   let timestampString = messageData["timestamp"] as? String,
                   let type = messageData["type"] as? String {
                    if let sentDate = self.convertTimestampStringToTimeInterval(timestampString) {
                        let sender = Sender(senderId: senderId, displayName: senderId)
                        let message = MockMessage(imageURL: downloadURL, sender: sender, messageId: newMessageRef.key ?? "", date: sentDate)
                        self.messages.append(message)
                        self.messages.sort(by: { $0.sentDate < $1.sentDate })
                        self.messagesCollectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension ChatViewController {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith attachments: [AttachmentManager.Attachment]) {
        for item in attachments {
            switch item {
            case .image(let image):
                sendImageMessage(photo: image)
            case .url(_): break
            case .data(_): break
            case .other(_): break
            }
        }
        inputBar.invalidatePlugins()
    }
}
