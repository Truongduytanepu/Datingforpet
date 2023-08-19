//
//  ChatViewController.swift
//  PetDating
//
//  Created by Trương Duy Tân on 17/08/2023.
//

import UIKit
import MessageKit

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
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let sender = Sender(senderId: "1", displayName: "John")
        let message1 = MockMessage(text: "Hello!", sender: sender, messageId: "1", date: Date())
        let message2 = MockMessage(text: "How are you?", sender: sender, messageId: "2", date: Date())
        
        messages.append(message1)
        messages.append(message2)
        
        // Reload dữ liệu để hiển thị tin nhắn
        messagesCollectionView.reloadData()
    }
}

extension ChatViewController: MessagesDataSource{
    func currentSender() -> MessageKit.SenderType {
        return Sender(senderId: "1", displayName: "John")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension ChatViewController: MessagesLayoutDelegate, MessagesDisplayDelegate{
    
}
