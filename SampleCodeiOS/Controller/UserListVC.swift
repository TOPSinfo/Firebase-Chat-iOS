//
//  UserListVC.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import UIKit

class userListCell : UITableViewCell {
    @IBOutlet weak var lbl_userName:UILabel!
}

protocol UserListVCDelegate: AnyObject {
    func getUserList()
}

class UserListVC: UIViewController {
    
    //MARK:- Variable
    let userViewModel : UserListViewModel = UserListViewModel()
    var userArray = [SignupUserData]()
    
    //MARK:- Outlet
    @IBOutlet weak var tbl_userList:UITableView!
    @IBOutlet weak var btn_logout:UIButton!
    var isFirstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set tableview delgate and datasource
        self.tbl_userList.delegate = self
        self.tbl_userList.dataSource = self
        
        //Will call to get list of register user
        userViewModel.userListVCDelegate?.getUserList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //set delegate of auth view model
        userViewModel.firebaseAuthViewModelDelegate = self
        
    }
    
    //MARK:- USer will logout from auth session and app
    @IBAction func btn_logout(_ sender:UIButton) {
        userViewModel.firebaseViewModel.logautUser { (isLogout) in
            Singleton.sharedSingleton.setNavigation()
        } failure: { (error) in
            Singleton.sharedSingleton.showToast(message: error)
        }
    }
    
}
//MArk:- extended Firebase Auth view model protocol
extension UserListVC : FirebaseAuthViewModelDelegate {
    //MARK: Will show error.
    func error(error: String, sign: Bool) {
        Singleton.sharedSingleton.showToast(message: error)
    }
    
    //will get call when user list recieve
    func didGetUserList(_ userlist: Array<Any>) {
        
        if let users = userlist as? [SignupUserData] {
            
            if isFirstTime {
                isFirstTime = false
                self.userArray = users
            } else {
                self.userArray.append(contentsOf: users)
            }
            self.tbl_userList.reloadData()
        }
        
    }
}


//MARK:- Extended tableview delegate and datasource method
extension UserListVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "userListCell") as! userListCell
        let item = self.userArray[indexPath.row]
        cell.lbl_userName.text = item.firstName + " " + item.lastName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = Singleton.sharedSingleton.getController(storyName: Singleton.storyboardName.Main, controllerName: Singleton.controllerName.ChatVC) as! ChatVC
        let item = self.userArray[indexPath.row]
        vc.userID = item.uid
        vc.userName = item.firstName + " " + item.lastName
        Singleton.sharedSingleton.navigate(from: self, to: vc, navigationController: self.navigationController)
    }
}
