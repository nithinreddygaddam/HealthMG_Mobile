//
//  SubscribtionViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/8/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit


class SubscribtionViewController: UIViewController {
    
    var pubSub = "Publishers"
    var publisherUsername: String!
    private var publishersList = [User]()
    private var subscribersList = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        publishersList = SubscriptionAPI.sharedInstance.getPublishers()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var btAdd: UIBarButtonItem!
    
    @IBOutlet weak var btPubSub: UIBarButtonItem!
    
    @IBAction func IBPubSub(sender: AnyObject) {
        if pubSub == "Publishers"{
            pubSub = "Subscribers"
            self.btAdd.enabled = false
            self.navBar.title = "Subscribers"
            self.btPubSub.image = UIImage(named: "connect-arrow-down-left-7.png")
            
            subscribersList = SubscriptionAPI.sharedInstance.getSubscribers()
            
        }
        else{
            pubSub = "Publishers"
            self.btAdd.enabled = true
            self.navBar.title = "Publishers"
            self.btPubSub.image = UIImage(named: "connect-arrow-up-right-7.png")
        }
        
    }
    
    @IBAction func IBAdd(sender: AnyObject) {
        askForPublisher()
    }
    
    func askForPublisher() {
        let alertController = UIAlertController(title: "Add Publisher", message: "Please enter a username:", preferredStyle: UIAlertControllerStyle.Alert)
        
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        let OKAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.Default) { (action) -> Void in
            let textfield = alertController.textFields![0]
            if textfield.text?.characters.count == 0 {
                self.askForPublisher()
            }
            else {
                self.publisherUsername = textfield.text
                
                SocketIOManager.sharedInstance.addSubscription(loggedUser.id, publishersUsername: self.publisherUsername, completionHandler: { (publisher) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if publisher != nil {
//                            publishersList.append(publisher)
                            
                            
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

    
    @IBOutlet weak var navBar: UINavigationItem!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
