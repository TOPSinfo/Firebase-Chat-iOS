//
//  RegisterUserVC.swift
//  SampleCodeiOS
//
//  Created by Tops on 04/10/21.
//

import UIKit
import Firebase


//MARK:- custom delegate methos
protocol RegisterUserVCDelegate: AnyObject {
    func buttonClicked(userID:String, dic:[String:Any])
}

class RegisterUserVC: UIViewController {
    
    //ARRK:- variable
    let registerViewModel : RegisterViewModel = RegisterViewModel()
    var userID = String()
    
    //MARK:- Outlet
    @IBOutlet weak var tf_FirstNmae:UITextField!
    @IBOutlet weak var tf_LastName:UITextField!
    @IBOutlet weak var tf_Email:UITextField!
    
    //MARK:- Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // will set delegate firebase Auth view model
        self.registerViewModel.firebaseAuthViewModelDelegate = self
    }
    
    //MARK:- Register button tapped
    @IBAction func btn_registerTapped(_ sender:UIButton) {
        
        if tf_FirstNmae.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterFirstName)
        } else if tf_LastName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterlastName)
        } else if tf_Email.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enteremail)
        } else if !Singleton.sharedSingleton.isValidEmail(tf_Email.text!) {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterValidemail)
        } else {
            
            var dic = [String:Any]()
            dic["email"] = self.tf_Email.text ?? ""
            dic["first_name"] = self.tf_FirstNmae.text ?? ""
            dic["last_name"] = self.tf_LastName.text ?? ""
            dic["phone"] = Auth.auth().currentUser?.phoneNumber
            dic["uid"] = Auth.auth().currentUser?.uid
            
            registerViewModel.registerVCDelegate?.buttonClicked(userID: Auth.auth().currentUser?.uid ?? "", dic: dic)
            
        }
        
    }
    
    @IBAction func btn_back(_ sender:UIButton) {
        registerViewModel.firebaseViewModel.logautUser { (isLogout) in
            Singleton.sharedSingleton.setNavigation()
        } failure: { (error) in
            Singleton.sharedSingleton.showToast(message: error)
        }
    }
    
}

//MARK:- Extended firebase Auth view model
extension RegisterUserVC : FirebaseAuthViewModelDelegate {
    
    //MARK: Will show error.
    func error(error: String, sign: Bool) {
        Singleton.sharedSingleton.showToast(message: error)
    }
    //register callback
    func register(_ isRegister: Bool) {
        
        if isRegister {
            let vc = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: Singleton.controllerName.UserListVC) as! UserListVC
            Singleton.sharedSingleton.navigate(from: self, to: vc, navigationController: self.navigationController)
        } 
        
    }
}
