//
//  FirebaseCloudFirestoreManager.swift
//  SampleCodeiOS
//
//  Created by Tops on 01/10/21.
//

import Foundation
import FirebaseFirestore
import CodableFirebase
import Firebase

class FirebaseCloudFirestoreManager {
    
    //MAR:- firestore database object
    var db: Firestore = Firestore.firestore()
    
    //MARK:- check user is registred or not
    func checkUserAvailableQuery(uid : String) -> Query {
        let userRef = db.collection("USER")
        return userRef.whereField("uid", isEqualTo: uid)
    }
    
    //MARK:- register User using basic detail
    func registerUser(userID:String, dic:[String:Any], completion: @escaping(() -> Void), failure: @escaping((_ error: String) -> Void)) {
        
        db.collection("USER").document(userID).setData(dic) { (error) in
            if let error = error{
                failure(error.localizedDescription)
            } else {
                completion()
            }
        }
    }
    
    //MARK:- get current user detail using user_id
    func getUserDetail(userID:String,completion: @escaping((_ arrayUsers: SignupUserData) -> Void), failure: @escaping((_ error: String) -> Void)){
        db.collection("USER").document(userID).getDocument(completion: { (documentSnapshot, error) in
            if let error = error {
                failure(error.localizedDescription)
            } else{
                if let documentSnapshot = documentSnapshot, documentSnapshot.exists {
                    do {
                        
                        if let document = documentSnapshot.data() {
                            let data = SignupUserData.init(fromDictionary: document)
                            completion(data)
                        } else {
                            completion(SignupUserData())
                        }
                    } catch {
                        failure(error.localizedDescription)
                    }
                } else {
                    failure("")
                }
            }
        })
    }
    
    
    //MARK:- Get all user who are registred in except self
    func getAlluser(completion: @escaping((_ arrayUsers: [SignupUserData]) -> Void), failure: @escaping((_ error: String) -> Void)){
        
        let uid = Auth.auth().currentUser?.uid ?? "0"
        
        db.collection("USER").whereField("uid", isNotEqualTo: uid).addSnapshotListener { QuerySnapshot, error  in
            
            if let error = error {
                failure(error.localizedDescription)
            } else {
                var array = [SignupUserData]()
                if let documents = QuerySnapshot?.documents, documents.count > 0 {
                    /// This is the on change listner
                    QuerySnapshot!.documentChanges.forEach({ (diff) in
                        if (diff.type == .added) {
                            let user = SignupUserData.init(fromDictionary: diff.document.data())
                            array.append(user)
                        }
                        else if (diff.type == .modified) {
                            
                        }
                        else if (diff.type == .removed) {
                            
                        }
                    })
                    completion(array)
                }
                
            }
        }
    }
    
    //MARK:- To creatd conversation ID
    //This will creare conversation id using both user ID
    func getOneToOneID(senderID:String,receiverID:String) -> String {
        
        if senderID < receiverID {
            return senderID + receiverID
        } else {
            return receiverID + senderID
        }
    }
    
    //MARK:- TO Get conversation between two users with realtime update lithner
    func getConversation(toUserid:String, completion: @escaping((_ arrayUsers: [MessageClass]) -> Void), failure: @escaping((_ error: String) -> Void)) {
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let docid = getOneToOneID(senderID: id, receiverID: toUserid)
        
        db.collection("Messages").document(docid).collection("message").order(by: "timestamp", descending: false).addSnapshotListener(includeMetadataChanges: false) { QuerySnapshot, error in
            
            if let error = error {
                
            } else {
                var messages = [MessageClass]()
                if let documents = QuerySnapshot?.documents, documents.count > 0 {
                    
                    /// This is the on change listner
                    QuerySnapshot!.documentChanges.forEach({ (diff) in
                        if (diff.type == .added) {
                            let message = MessageClass.init(fromDictionary: diff.document.data())
                            messages.append(message)
                        }
                        else if (diff.type == .modified) {
                            
                        }
                        else if (diff.type == .removed) {
                            
                        }
                    })
                    completion(messages)
                    
                }
                
            }
            
        }

    }
    
    //MARK:- TO send message - one to one chat
    func sendMessage(senderID:String,touserID:String,dic:[String:Any], completion: @escaping((_ arrayUsers: MessageClass) -> Void), failure: @escaping((_ error: String) -> Void)) {
        
        let docid = getOneToOneID(senderID: senderID, receiverID: touserID)
        
        db.collection("Messages").document(docid).collection("message").document().setData(dic) { (error) in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                let message = MessageClass.init(fromDictionary: dic)
                completion(message)
            }
        }
    }
    
}
