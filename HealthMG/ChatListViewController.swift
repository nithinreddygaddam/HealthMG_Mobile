//
//  ChatListViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/12/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    private var conversationsList = [[String: AnyObject]]()
    private var user2: [String: AnyObject]?
    private var conversationID: String?
    let reuseIdentifier = "programmaticCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Recent Chats"

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        conversationsList.removeAll()
        
        SocketIOManager.sharedInstance.getConversationsList( loggedUser.id, completionHandler: { (conversationsList) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if(conversationsList != nil){
                    self.conversationsList = conversationsList!
                    self.tableView.registerClass(MGSwipeTableCell.self, forCellReuseIdentifier: self.reuseIdentifier)
                    self.tableView.reloadData()
                }
            })
        })
    }
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationsList.count;
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! MGSwipeTableCell!
        
        if cell == nil
        {
            cell = MGSwipeTableCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
        }
            cell.textLabel?.text = conversationsList[indexPath.row]["name"] as? String!
            cell.detailTextLabel?.text = conversationsList[indexPath.row]["text"] as? String!
        
        //configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"message-7.png"), backgroundColor: UIColor.greenColor(),
            callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                
                self.user2 = self.conversationsList[indexPath.row]["user"] as! [String: AnyObject]!
                self.conversationID = self.conversationsList[indexPath.row]["id"] as! String!
                self.performSegueWithIdentifier("chatSegue", sender: nil)

                return true
        })]
        cell.leftSwipeSettings.transition = MGSwipeTransition.Rotate3D
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor(),
            callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                SocketIOManager.sharedInstance.deleteChat(self.conversationID!)
                return true
        })]
        
        cell.rightSwipeSettings.transition = MGSwipeTransition.Rotate3D
        
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "chatSegue") {
            let cwvc = segue.destinationViewController as! ChatWindowController;
            cwvc.user2 = self.user2!
            cwvc.conversationID = self.conversationID
        }
        
    }

    
}