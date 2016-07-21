//
//  ChatWindowController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/17/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

class ChatWindowController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate{

    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var tvMessageEditor: UITextView!
    var user2: [String: AnyObject] = [ : ]
    var user2Name: String!
    var loggedUserName: String!
    var conversationID: String?
    
    //    @IBOutlet weak var conBottomEditor: NSLayoutConstraint!
    
    var chatMessages = [[String: AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstName = user2["firstName"] as? String
        let lastName = user2["lastName"] as? String
        user2Name = firstName! + " " + lastName!
        
        loggedUserName = loggedUser.fName! + " " + loggedUser.lName!
        
        self.navigationItem.title = user2Name
        self.tabBarController?.tabBar.hidden = true
        
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ChatWindowController.dismissKeyboard))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        swipeGestureRecognizer.delegate = self
        view.addGestureRecognizer(swipeGestureRecognizer)
        
        if self.conversationID == nil {
            SocketIOManager.sharedInstance.getConversationID(loggedUser.id, user2: user2["_id"] as! String, completionHandler: { (conversation) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if conversation != nil{
                        self.conversationID = conversation!
                        self.getMsgs()
                    }
                })
            })
            
        }
        else{
            self.getMsgs()
        }
        
    }
    
    func getMsgs(){
        self.chatMessages.removeAll()
        
        SocketIOManager.sharedInstance.getMessages(conversationID! , completionHandler: { (chat) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if chat != nil {
                    var messageDictionary = [String: AnyObject]()
                    for msg in chat!{
                        messageDictionary["from"] = msg["from"] as! String
                        messageDictionary["message"] = msg["text"] as! String
                        messageDictionary["date"] = msg["created_at"] as! String
                        messageDictionary["conversation"] = msg["conversation"] as! String
                        self.chatMessages.append(messageDictionary)
                        self.tblChat.reloadData()
                    }
                }
            })
        })

    }
    
    override func viewWillDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tvMessageEditor.delegate = self

        configureTableView()

    }
    
    //Method used to recieve message
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketIOManager.sharedInstance.getChatMessage { (messageInfo) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.conversationID == nil {
                    self.conversationID = messageInfo!["conversation"] as? String
                }
                self.chatMessages.append(messageInfo!)
                self.tblChat.reloadData()
            })
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: IBAction Methods
    // Checks weather there is a message to send then sends the message an clears the editor and closes the keyboard
    @IBAction func sendMessage(sender: AnyObject) {
        if tvMessageEditor.text.characters.count > 0 {
            SocketIOManager.sharedInstance.sendMessage(conversationID!,loggedUser: loggedUser.id, user2: user2["_id"] as! String, message: tvMessageEditor.text!)
            tvMessageEditor.text = ""
            tvMessageEditor.resignFirstResponder()
        }
    }
    
    
    func configureTableView() {
        tblChat.delegate = self
        tblChat.dataSource = self
        tblChat.registerNib(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "idCellChat")
        tblChat.estimatedRowHeight = 90.0
        tblChat.rowHeight = UITableViewAutomaticDimension
        tblChat.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func scrollToBottom() {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { () -> Void in
            if self.chatMessages.count > 0 {
                let lastRowIndexPath = NSIndexPath(forRow: self.chatMessages.count - 1, inSection: 0)
                self.tblChat.scrollToRowAtIndexPath(lastRowIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    
    
    func dismissKeyboard() {
        if tvMessageEditor.isFirstResponder() {
            tvMessageEditor.resignFirstResponder()
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    //adjusts the recieved messages to left and sent to the right
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellChat", forIndexPath: indexPath) as! ChatCell
        let currentChatMessage = chatMessages[indexPath.row]
        let from = currentChatMessage["from"] as! String?
        let message = currentChatMessage["message"] as! String?
        let messageDate = currentChatMessage["date"] as! String?
        if (from == loggedUser.id) {
            cell.lblChatMessage.textAlignment = NSTextAlignment.Right
            cell.lblMessageDetails.textAlignment = NSTextAlignment.Right
//            cell.lblChatMessage.textColor = lblNewsBanner.backgroundColor
            cell.lblMessageDetails.text = "by \(loggedUserName) @ \(messageDate)"
        }
        else {
            cell.lblMessageDetails.text = "by \(user2Name) @ \(messageDate)"
        }
        
        cell.lblChatMessage.text = message
        
        cell.lblChatMessage.textColor = UIColor.darkGrayColor()
        
        return cell
    }
    
}
