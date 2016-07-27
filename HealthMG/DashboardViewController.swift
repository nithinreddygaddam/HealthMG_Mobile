//
//  DashboardViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/8/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tblView: UITableView!
    
    var configurationOK = false
    let reuseIdentifier = "idCellDashboard"
    
    let attributes:[String] = ["Steps", "Distance", "Calories", "Heart Rate"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !configurationOK {
            configureNavigationBar()
            configureTableView()
            configurationOK = true
        }
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "detailDashboardSegue" {
//                let chatViewController = segue.destinationViewController as! ChatViewController
//                chatViewController.nickname = nickname
            }
        }
    }
    
    
    func configureNavigationBar() {
        navigationItem.title = "DashBoard"
    }
    
    
    func configureTableView() {
        tblView.delegate = self
        tblView.dataSource = self
        tblView.registerNib(UINib(nibName: "DashboardCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
//        tblView.hidden = true
        tblView.estimatedRowHeight = 133.0
        tblView.rowHeight = UITableViewAutomaticDimension
        tblView.tableFooterView = UIView(frame: CGRectZero)
        
    }
    
    
    // MARK: UITableView Delegate and Datasource methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributes.count
    }
        
    //displays user's information
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:DashboardCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! DashboardCell
        
//        cell. = attributes[indexPath.row]
        let yaxis = ["1","2","3"]
        let rates = [4.0,5.0,6.0]
        cell.setChart(yaxis, values: rates)
        let newView = UIView(frame: CGRectMake(200, 10, 100, 50))
        cell.contentView.addSubview(newView)
//        cell.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
//        cell.detailTextLabel?.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.greenColor() : UIColor.redColor()
        
        
        return cell
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 133.0
//    }

}
