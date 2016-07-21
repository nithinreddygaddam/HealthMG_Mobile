//
//  DashboardViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/8/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

//class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
class DashboardViewController: UIViewController {
    
    @IBOutlet weak var tblView: UITableView!
    
    var configurationOK = false
    let reuseIdentifier = "idCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if !configurationOK {
//            configureTableView()
//            configurationOK = true
//        }
//        
//    }
//    
//    func configureTableView() {
//        tblView.delegate = self
//        tblView.dataSource = self
//        tblView.registerNib(UINib(nibName: "DashboardCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
////        tblView.hidden = true
//        tblView.tableFooterView = UIView(frame: CGRectZero)
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let identifier = segue.identifier {
//            if identifier == "detailDashboardSegue" {
////                let chatViewController = segue.destinationViewController as! ChatViewController
////                chatViewController.nickname = nickname
//            }
//        }
//    }
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
////        return users.count
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! DashboardCell
//        
////        cell.textLabel?.text = users[indexPath.row]["nickname"] as? String
////        cell.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
////        cell.detailTextLabel?.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.greenColor() : UIColor.redColor()
////        
//        
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 44.0
//    }

}
