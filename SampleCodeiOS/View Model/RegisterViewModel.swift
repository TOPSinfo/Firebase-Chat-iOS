//
//  RegisterViewModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 04/10/21.
//

import Foundation

final class RegisterViewModel {
    
    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()
    var registerVCDelegate: RegisterUserVCDelegate?
    var firebaseAuthViewModelDelegate: FirebaseAuthViewModelDelegate?
    
    init() {
        self.registerVCDelegate = self
    }
    
}

extension RegisterViewModel : RegisterUserVCDelegate {
    //Button click from cotroller and register user in databse
    func buttonClicked(userID:String, dic:[String:Any]) {
        
        firebaseViewModel.firebaseCloudFirestoreManager.registerUser(userID: userID, dic: dic) {
            self.firebaseAuthViewModelDelegate?.register?(true)
        } failure: { (error) in
            self.firebaseAuthViewModelDelegate?.error?(error: error, sign: false)
        }
        
    }
}
