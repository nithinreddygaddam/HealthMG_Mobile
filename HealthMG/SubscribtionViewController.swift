//
//  SubscribtionViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/8/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import ChameleonFramework

var subscribtion: [String: AnyObject] = [ : ]

class SubscribtionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var publisherUsername: String!
    private var publishersList = [[String: AnyObject]]()
    private var user2: [String: AnyObject] = [ : ]
    
    @IBOutlet var tableView: UITableView!
    
    var rightButton : UIBarButtonItem!
    var leftButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        leftButton = UIBarButtonItem(image: UIImage(named:"up-arrow.png"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(IBPubSub))
        rightButton = UIBarButtonItem(image: UIImage(named:"plus-simple-7.png"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(askForPublisher))
        self.navigationItem.leftBarButtonItem = leftButton
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.title = "Publishers"
        
        publishersList.removeAll()
        
        SocketIOManager.sharedInstance.getPublishers(loggedUser.id, completionHandler: { (publishers) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.publishersList = publishers!
                self.tableView.registerClass(MGSwipeTableCell.self, forCellReuseIdentifier: "cell")
                self.tableView.reloadData()
            })
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "chatSegue2") {
            let cwvc = segue.destinationViewController as! ChatWindowController;
            cwvc.user2 = user2
        }
        else if(segue.identifier == "permissionSegue") {
            let pvc = segue.destinationViewController as! PermissionViewController;
            pvc.user2 = user2
        }

    }
    
//    func doNothing(){}
    
    
    func IBPubSub() {
        
        self.performSegueWithIdentifier("subSegue", sender: nil)
        
    }
    
    func askForPublisher() {
        let alertController = UIAlertController(title: "Add Publisher", message: "Please enter a username:", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        let OKAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 || textfield.text?.lowercaseString == loggedUser.username {
                self.askForPublisher()
            }
            else {
                self.publisherUsername = textfield.text
                
                SocketIOManager.sharedInstance.requestSubscription(loggedUser.id, publishersUsername: self.publisherUsername, completionHandler: { (publisher) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if publisher != nil {
                            self.publishersList.append(publisher!)
                            self.tableView.registerClass(MGSwipeTableCell.self, forCellReuseIdentifier: "cell")
                            self.tableView.reloadData()
                        }
                    })
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
            NSLog("Cancel Pressed")
        }
        
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return publishersList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("cell") as! MGSwipeTableCell!
        
        var firstName: String?
        var lastName: String?
        var Name: String?
        
        if cell == nil
        {
            cell = MGSwipeTableCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }

        
        if publishersList.count > 0{
            firstName = publishersList[indexPath.row]["firstName"] as? String
            lastName = publishersList[indexPath.row]["lastName"] as? String
            Name = firstName! + " " + lastName!
            cell.textLabel?.text = Name
        }
        else{
            cell.textLabel?.text = " "
        }
        
        //configure left buttons
        cell.leftButtons = [MGSwipeButton(title: "", icon: UIImage(named:"message-7.png"), backgroundColor: UIColor.flatGreenColor(),
            callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                self.user2 = self.publishersList[indexPath.row]
                self.performSegueWithIdentifier("chatSegue2", sender: nil)

                return true
            })]
        cell.leftSwipeSettings.transition = MGSwipeTransition.Rotate3D
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.flatRedColor(),
            callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                SocketIOManager.sharedInstance.deletePublisher(loggedUser.id, publisher: self.publishersList[indexPath.row])
                self.publishersList.removeAtIndex(indexPath.row)
                self.tableView.reloadData()
                return true
            })
//            ,MGSwipeButton(title: "More",backgroundColor: UIColor.flatGrayColor(),
//                callback: {
//                    (sender: MGSwipeTableCell!) -> Bool in
//                    print("Convenience callback for swipe buttons3!")
//                    return true
//                })
        ]
        
        cell.rightSwipeSettings.transition = MGSwipeTransition.Rotate3D

        
        return cell
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }
 

}
