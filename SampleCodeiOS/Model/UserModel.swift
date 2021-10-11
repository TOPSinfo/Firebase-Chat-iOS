//
//  UserModel.swift
//  SampleCodeiOS
//
//  Created by Tops on 04/10/21.
//

import Foundation
import FirebaseFirestore
import UIKit

//This is user model
class SignupUserData {
    
    var email : String = ""
    var firstName : String = ""
    var lastName : String = ""
    var phone : String = ""
    var uid : String = ""

    init() {
        
    }
    
    init(fromDictionary dictionary: [String:Any]){
        email = dictionary["email"] as? String ?? ""
        firstName = dictionary["first_name"] as? String ?? ""
        lastName = dictionary["last_name"] as? String ?? ""
        phone = dictionary["phone"] as? String ?? ""
        uid = dictionary["uid"] as? String ?? ""
    }

}
