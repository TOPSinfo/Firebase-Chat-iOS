//
//  Singleton.swift
//  SampleCodeiOS
//
//  Created by Tops on 01/10/21.
//

import Foundation
import UIKit
import MBProgressHUD
import Toast_Swift
import Firebase

class Singleton  : NSObject {
    
    typealias SucessBlock = (_ return   : Bool) -> Void
    typealias textFieldTextBlock = (_ returnText : String,_ isSubmitPressed : Bool) -> Void
    //MARK:-  Singleton Object 
    
    static let sharedSingleton = Singleton()
    static let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    static var progresshud = MBProgressHUD()
    
    //MARK:- App color user to set programatically
    struct appColors {
//        static let purpoleSelected : UIColor = UIColor(red: 150.0/255.0, green: 0.0/255.0, blue: 124.0/255.0, alpha: 1.0)
       
        static let themeColoer : UIColor = UIColor(named: "ic_app_bar_color")!
        
        static let grayColor : UIColor = UIColor(red: 123.0/255.0, green: 122.0/255.0, blue: 124.0/255.0, alpha: 1.0)
    }
    //MARK:- set Conditional navgation
    func setNavigation(){
        
        if Auth.auth().currentUser != nil {
            //MARK:- user is login
            if let userID = Auth.auth().currentUser?.uid {
                let firebaseViewModel : FirebaseViewModel = FirebaseViewModel()
                
                Singleton.sharedSingleton.showLoder()
                firebaseViewModel.firebaseCloudFirestoreManager.checkUserAvailableQuery(uid: userID).getDocuments { (documents, err) in
                    Singleton.sharedSingleton.hideLoader()
                    if let err = err {
                        Singleton.sharedSingleton.showToast(message: err.localizedDescription)
                    } else {
                        if ((documents?.documents.count)! > 0){
                            self.goToUserList()
                        } else {
                            self.goToRegistration()
                        }
                    }
                }
            }
           
        } else {
            //MARK:- user is logout
            goToLogin()
        }
    }
    
    //MARK:- GO To Registration page
    func goToRegistration() {
        let navVC = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: "InitialNavigation") as! UINavigationController
        let vc = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: Singleton.controllerName.RegisterUserVC)
        navVC.viewControllers = [vc]
        if let window = Singleton.appDelegate.window {
            window.rootViewController = navVC
            window.makeKeyAndVisible()
        }
    }
    //MARK:- GO TO User List dashboard
    func goToUserList() {
        let navVC = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: "InitialNavigation") as! UINavigationController
        let vc = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: Singleton.controllerName.UserListVC)
        navVC.viewControllers = [vc]
        if let window = Singleton.appDelegate.window {
            window.rootViewController = navVC
            window.makeKeyAndVisible()
        }
    }
    //MARK:- GO TO Login Page
    func goToLogin() {
        let navVC = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: "InitialNavigation") as! UINavigationController
        let vc = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: Singleton.controllerName.AddMobileViewController)
        navVC.viewControllers = [vc]
        if let window = Singleton.appDelegate.window {
            window.rootViewController = navVC
            window.makeKeyAndVisible()
        }
    }
    //MARK: Loader Methods
    func showLoder()
    {
        if let window = Singleton.appDelegate.window {
            MBProgressHUD.showAdded(to: window, animated: true)
        }
    }
    
    func hideLoader(){
        if let window = Singleton.appDelegate.window {
            MBProgressHUD.hide(for: window, animated: true)
        }
    }
    
    //MARK:- Show Toast messages
    func showToast(message: String) {

        let window = UIApplication.shared.windows
        window.last?.makeToast(message, duration: 3.0, position: .bottom)

    }
    
    //MARK:- Alert Message
    struct alertMessages {
        static let enterMobileNumber : String           = "Please enter mobile number"
        static let enterValidMobileNumber : String      = "Please enter valid mobile number"
        static let enterProperPin : String              = "Please enter pin number"
        static let wrongPin : String                    = "Invalid code. Please try again"
        static let somethingWentWrong : String          = "We have not sent OTP yet.Please wait for some time"
        static let otpExpired : String                  = "This code has expired. Please resend for a new code"
        static let enterFirstName : String              = "Please enter first name"
        static let enterlastName : String               = "Please enter last name"
        static let enteremail : String                  = "Please enter e-mail address"
        static let enterValidemail : String             = "Please enter valid e-mail address"
        static let enterMessage : String                = "Please enter message"
    }
    
    //MARK:- Storyboards
    struct storyboardName {
        static let Main = "Main"
    }
    //MARK:- Controllers
    struct controllerName {
        static let AddMobileViewController  = "addMobileViewController"
        static let OTPViewController        = "OTPViewController"
        static let RegisterUserVC           = "RegisterUserVC"
        static let UserListVC               = "UserListVC"
        static let ChatVC                   = "ChatVC"
    }
    //MARK:- TO get storyboards
    func getStoryBoard (storyboardName : String) -> UIStoryboard{
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard
    }
                                            
    //MARK:- To get Controllers
    func getController (storyName : String,controllerName : String) -> UIViewController{
        var controller  = UIViewController()
        if #available(iOS 13.0, *) {
            controller = getStoryBoard(storyboardName: storyName).instantiateViewController(identifier: controllerName)
        } else {
            controller = getStoryBoard(storyboardName: storyName).instantiateViewController(withIdentifier: controllerName)
            // Fallback on earlier versions
        }
        return controller
    }
   //MARK:- To navigate from one to another controller
    func navigate(from : UIViewController?, to : UIViewController?, navigationController : UINavigationController?)  {
        if from != nil && to != nil && navigationController != nil{
            navigationController!.pushViewController(to!, animated: true)
        }
    }
    
    //MARK:- TO validate Email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}

