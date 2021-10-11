//
//  MessageModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import Foundation

//Comversation model
class MessageClass{

    var messageText : String = ""
    var receiverId : String = ""
    var senderId : String = ""
    var timestamp : String = ""
    
    init() {
        
    }

    init(fromDictionary dictionary: [String:Any]){
        messageText = dictionary["messageText"] as? String ?? ""
        receiverId = dictionary["receiverId"] as? String ?? ""
        senderId = dictionary["senderId"] as? String ?? ""
        timestamp = dictionary["timestamp"] as? String ?? ""
    }

}
