//
//  FirebaseViewModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 04/10/21.
//

import Foundation
import Firebase


final class FirebaseViewModel {
    
    let firebaseAuthManager: FirebaseAuthManager = FirebaseAuthManager()
    let firebaseCloudFirestoreManager: FirebaseCloudFirestoreManager = FirebaseCloudFirestoreManager()
    
    init() {
        
    }
    
    //Verify Phone method
    func verifyPhone(phone:String, completion: @escaping((_ verificationID:String) -> Void), failure: @escaping((_ error: String) -> Void)){
    
        firebaseAuthManager.verifyPhoneNumber(phoneNumber: phone) { (id, error) in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                completion(id)
            }
        }
    }
    
    //MARK:- Login callback
    func login(credential:PhoneAuthCredential, completion: @escaping((_ authResult: AuthDataResult?) -> Void), failure: @escaping((_ error: String) -> Void)) {
        
        firebaseAuthManager.login(credential:credential) { (result, error) in
            if let error = error {
                failure(error.localizedDescription)
            } else {
                completion(result)
            }
        }
    }
    //MARK: Logout callback
    func logautUser(completion: @escaping((_ isLogOut: Bool) -> Void), failure: @escaping((_ error: String) -> Void)){
        Singleton.sharedSingleton.showLoder()
        firebaseAuthManager.signOut(completion: {
            Singleton.sharedSingleton.hideLoader()
            completion(true)
        }) { (error) in
            Singleton.sharedSingleton.hideLoader()
            failure(error)
        }
    }
   
}

