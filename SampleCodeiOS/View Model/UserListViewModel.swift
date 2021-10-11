//
//  UserListViewModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import Foundation

final class UserListViewModel {
    
    let firebaseViewModel: FirebaseViewModel = FirebaseViewModel()
    var userListVCDelegate: UserListVCDelegate?
    var firebaseAuthViewModelDelegate: FirebaseAuthViewModelDelegate?
    
    init() {
        self.userListVCDelegate = self
    }
    
}

extension UserListViewModel : UserListVCDelegate {
    //will get user list from firestore and send back to controller to list
    func getUserList() {
        Singleton.sharedSingleton.showLoder()
        firebaseViewModel.firebaseCloudFirestoreManager.getAlluser { (arrayOfUser) in
            Singleton.sharedSingleton.hideLoader()
            self.firebaseAuthViewModelDelegate?.didGetUserList?(arrayOfUser)
        } failure: { (error) in
            Singleton.sharedSingleton.hideLoader()
            self.firebaseAuthViewModelDelegate?.error?(error: error, sign: false)
        }
    }
    
}
