//
//  ChatVC.swift
//  SampleCodeiOS
//
//  Created by Tops on 05/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore
import IQKeyboardManagerSwift

//MARK:- Custom delegate
protocol ChatVCDelegate: AnyObject {
    func getMessageList(_ touserID:String)
    func sendMessage(senderID:String, toUserID:String, dic:[String:Any])
}


class ChatVC: UIViewController {

    //MARK:- chat view model object
    let chatviewmodel : ChatViewModel = ChatViewModel()
    
    //MARK:- outlet
    @IBOutlet weak var tv_message:KMPlaceholderTextView!
    @IBOutlet weak var btn_send:UIButton!
    @IBOutlet weak var constant_ht_textfview:NSLayoutConstraint!
    
    @IBOutlet weak var tbl_chat:UITableView!
    @IBOutlet weak var btn_back:UIButton!
    @IBOutlet weak var lbl_title:UILabel!
    
    @IBOutlet weak var contant_bottom_of_textfield : NSLayoutConstraint!
    
    //MARK:- Variable
    var userID = String()
    var messaes = [MessageClass]()
    var isFirstTime = true
    var userName = String()
    
    //MARK:- Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK:- user to dismiss keyboar  on touch
        self.dismissKey()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        chatviewmodel.firebasechatViewModelDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    //MARK:- Setup UI
    func setupView() {
        
        self.lbl_title.text = userName
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        tbl_chat.register(UINib(nibName: "ChatReceiverCell", bundle: nil), forCellReuseIdentifier: "ChatReceiverCell")
        tbl_chat.register(UINib(nibName: "ChatSenderCell", bundle: nil), forCellReuseIdentifier: "ChatSenderCell")
        
        tbl_chat.delegate = self
        tbl_chat.dataSource = self
        
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        chatviewmodel.chatVCDelegate?.getMessageList(userID)
    }
    
    //MARK:- Keyboard methods
    func dismissKey()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(dismissKeyboard(sender:)))
        tap.cancelsTouchesInView = false
        tbl_chat.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(sender:UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.contant_bottom_of_textfield.constant == 8 {
                if #available(iOS 13.0, *) {
                    let window = Singleton.appDelegate.window
//                    let topPadding = window?.safeAreaInsets.top
                    let bottomPadding = window?.safeAreaInsets.bottom
                    UIView.animate(withDuration: 1.0) {
                        self.contant_bottom_of_textfield.constant = keyboardSize.height + 8 - (bottomPadding ?? 0)
                        self.view.layoutSubviews()
                    }
                    
                    
                } else {
                    let window = Singleton.appDelegate.window
//                        let topPadding = window?.safeAreaInsets.top
                        let bottomPadding = window?.safeAreaInsets.bottom
                    
                    UIView.animate(withDuration: 1.0) {
                        self.contant_bottom_of_textfield.constant = keyboardSize.height + 8 - (bottomPadding ?? 0)
                        self.view.layoutSubviews()
                    }
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.contant_bottom_of_textfield.constant != 0 {
            self.contant_bottom_of_textfield.constant = 8
        }
    }
    
    //MARK:- will scroll at last position when new message arrive or send
    private func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.tbl_chat.numberOfRows(inSection:  0) - 1,
                section: 0)
            if self.tbl_chat.numberOfRows(inSection:  0) > 1 {
                self.tbl_chat.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    
    //MARK:- Button Action
    @IBAction func btn_sendMessageTapped(_ sender:UIButton) {
        
        if tv_message.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Singleton.sharedSingleton.showToast(message: Singleton.alertMessages.enterMessage)
            return
        }
        
        let senderID = Auth.auth().currentUser?.uid ?? ""
        
        let time : Timestamp = Timestamp(date: Date())
        
        var dic = [String:Any]()
        dic["messageText"] = self.tv_message.text ?? ""
        dic["receiverId"] = userID
        dic["senderId"] = senderID //Current User
        dic["timestamp"] = time
        
        //MARK:- this will call send message controller
        self.chatviewmodel.chatVCDelegate?.sendMessage(senderID: senderID, toUserID: userID, dic: dic)
        
    }
    
    @IBAction func btn_backTapped(_ sender:UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

//MARK:- Tableview Delegate
extension ChatVC : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messaes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = self.messaes[indexPath.row]
        
        if item.senderId == Auth.auth().currentUser?.uid ?? "" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSenderCell") as! ChatSenderCell
            cell.lbl_message.text = item.messageText
            cell.layoutSubviews()
            
            DispatchQueue.main.async {
                cell.view_bubble.roundCorners([.topLeft,.bottomLeft, .bottomRight], radius: 5)
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatReceiverCell") as! ChatReceiverCell
            cell.lbl_message.text = item.messageText
            cell.layoutSubviews()
            DispatchQueue.main.async {
                cell.view_bubble.roundCorners([.topRight,.bottomLeft, .bottomRight], radius: 5)
                
            }
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARk:- Extended firebase chat medel view
extension ChatVC : FirebaseChatViewModelDelegate {
    
    func didSendMessage(_ message: Any) {
        self.tv_message.text = ""
    }
    
    func getMessages(_ arrayMessage: Array<Any>) {
        if let array = arrayMessage as? [MessageClass] {
            if isFirstTime {
                isFirstTime = false
                self.messaes = array
            } else {
                self.messaes.append(contentsOf: array)
            }
            
        }
        self.tbl_chat.reloadData()
        scrollToBottom()
    }
    
    //MARK: Will show error.
    func error(error: String, sign: Bool) {
        Singleton.sharedSingleton.showToast(message: error)
    }
}
