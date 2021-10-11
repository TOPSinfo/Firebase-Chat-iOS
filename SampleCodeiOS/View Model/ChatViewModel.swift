//
//  ChatViewModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import Foundation

@objc protocol FirebaseChatViewModelDelegate {
    @objc optional func getMessages(_ arrayMessage:Array<Any>)
    @objc optional func didSendMessage(_ message:Any)
    @objc optional func error(error: String, sign: Bool)
}

final class ChatViewModel {
    
    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()
    var chatVCDelegate: ChatVCDelegate?
    var firebasechatViewModelDelegate: FirebaseChatViewModelDelegate?
    
    init() {
        self.chatVCDelegate = self
    }
    
}

extension ChatViewModel : ChatVCDelegate {
    // will send message to reciever using IDs and get revert to controller
    func sendMessage(senderID:String, toUserID: String, dic: [String : Any]) {
        
        firebaseViewModel.firebaseCloudFirestoreManager.sendMessage(senderID: senderID, touserID: toUserID, dic: dic) { message in
            self.firebasechatViewModelDelegate?.didSendMessage?(message)
        } failure: { error in
            self.firebasechatViewModelDelegate?.error?(error: error, sign: true)
        }
    }
    
    //Will get message list between two users  and send back to controller
    func getMessageList(_ touserID: String) {
//
        firebaseViewModel.firebaseCloudFirestoreManager.getConversation(toUserid: touserID) { (messases) in
            self.firebasechatViewModelDelegate?.getMessages?(messases)
        } failure: { (error) in
            self.firebasechatViewModelDelegate?.error?(error: error, sign: false)
        }
        
    }
   
}
