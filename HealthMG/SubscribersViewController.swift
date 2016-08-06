//
//  SubscribersViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 8/5/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class SubscribersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var publisherUsername: String!
    @IBOutlet weak var tableView: UITableView!
    private var subscribersList = [[String: AnyObject]]()
    private var user2: [String: AnyObject] = [ : ]


    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribersList.removeAll()
        self.tableView.hidden = true
        
        SocketIOManager.sharedInstance.getSubscribers(loggedUser.id, completionHandler: { (subscribers) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.subscribersList = subscribers!
                self.tableView.registerClass(MGSwipeTableCell.self, forCellReuseIdentifier: "cell")
                self.tableView.hidden = false
                self.tableView.reloadData()
            })
        })

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "chatSegue3") {
            let cwvc = segue.destinationViewController as! ChatWindowController;
            cwvc.user2 = user2
        }
        else if(segue.identifier == "permissionSegue") {
            let pvc = segue.destinationViewController as! PermissionViewController;
            pvc.user2 = user2
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return subscribersList.count
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
        
        if subscribersList.count > 0{
            firstName = subscribersList[indexPath.row]["firstName"] as? String
            lastName = subscribersList[indexPath.row]["lastName"] as? String
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
                self.user2 = self.subscribersList[indexPath.row]
                self.performSegueWithIdentifier("chatSegue3", sender: nil)
                
                return true
        })]
        cell.leftSwipeSettings.transition = MGSwipeTransition.Rotate3D
        
        //configure right buttons
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: UIColor.flatRedColor(),
            callback: {
                (sender: MGSwipeTableCell!) -> Bool in
                SocketIOManager.sharedInstance.deleteSubscriber(loggedUser.id, subscriber: self.subscribersList[indexPath.row])
                self.subscribersList.removeAtIndex(indexPath.row)
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
        if subscribersList.count > 0{
            SocketIOManager.sharedInstance.getSubscribtion(loggedUser.id, subscriberID: subscribersList[indexPath.row]["_id"] as! String, completionHandler: {(subscribtion2) -> Void in
                dispatch_async(dispatch_get_main_queue(), {
                    subscribtion = subscribtion2!
                    self.user2 = self.subscribersList[indexPath.row]
                    self.performSegueWithIdentifier("permissionSegue", sender: nil)
                })
            })
            
        }
    }


}
