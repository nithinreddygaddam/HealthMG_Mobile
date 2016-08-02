//
//  DashboardViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/8/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import HealthKit
import Async
import ChameleonFramework

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tblView: UITableView!
    
    var configurationOK = false
    let reuseIdentifier = "idCellDashboard"
    //x and y axis are interchanged here
    var yAxis:[[String]]  = []
    var xAxis:[[Double]]  = []
    var yAxisTemp:[String]  = []
    var xAxisTemp:[Double]  = []
    var xAxisMin:[Double]  = []
    var xAxisMax:[Double]  = []
    var stats:[Double]  = []
    var total = 0.0
    var min = 0.0
    var max = 0.0
    var index = 0
    
    let attributes:[String] = ["Steps", "Distance", "Calories", "Heart Rate"]
    let units:[String] = [" ", "miles", "kcal", "bpm"]
    let colors:[UIColor] = [FlatSkyBlue(), FlatLime(), FlatYellow(), FlatWatermelon()]
    let weekdays = [
        "nil",
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu",
        "Fri",
        "Sat"
    ]
    
    private let healthKitManager = HealthKitManager.sharedInstance
    private var steps = [HKQuantitySample]()
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestHealthKitAuthorization()
        //disabling to tabs in the offline mode
        if loggedUser.id == nil {
            if  let arrayOfTabBarItems = tabBarController!.tabBar.items as! AnyObject as? NSArray,tabBarItem = arrayOfTabBarItems[2] as? UITabBarItem {
                tabBarItem.enabled = false
            }
            if  let arrayOfTabBarItems = tabBarController!.tabBar.items as! AnyObject as? NSArray,tabBarItem = arrayOfTabBarItems[1] as? UITabBarItem {
                tabBarItem.enabled = false
            }
        }
        
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
                let detailDashboardViewController = segue.destinationViewController as! DetailDashboardViewController
                detailDashboardViewController.index = index
            }
        }
    }
    
    
    func configureNavigationBar() {
        navigationItem.title = "Dashboard"
    }
    
    
    func configureTableView() {
        tblView.delegate = self
        tblView.dataSource = self
        tblView.registerNib(UINib(nibName: "DashboardCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tblView.registerNib(UINib(nibName: "HeartRateCell", bundle: nil), forCellReuseIdentifier: "idCellHeartRate")
        tblView.estimatedRowHeight = 133.0
        tblView.rowHeight = UITableViewAutomaticDimension
        tblView.tableFooterView = UIView(frame: CGRectZero)
        tblView.hidden = true
        
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
        
        if attributes[indexPath.row] == "Heart Rate"{
            let cell2:HeartRateCell = tableView.dequeueReusableCellWithIdentifier("idCellHeartRate") as! HeartRateCell
            cell2.lblStatMin.text = String(min)
            cell2.lblStatMax.text = String(max)
            // x and y are interchanged
            if (yAxis.count == (attributes.count)){
            cell2.setChartData(yAxis[indexPath.row], yAxisMax: xAxisMax, yAxisMin : xAxisMin)
            }
            return cell2
        }
        else{
            let cell:DashboardCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as! DashboardCell
            cell.lblAtrribute.text = attributes[indexPath.row]
            cell.lblAtrribute.textColor = colors[indexPath.row]
            if (yAxis.count == (attributes.count)){
                cell.lblStat.text = String(round(100.0 * stats[indexPath.row]) / 100.0)
                cell.lblStat.textColor = colors[indexPath.row]
                cell.lblUnit.text = units[indexPath.row]
                cell.lblUnit.textColor = colors[indexPath.row]
                cell.color = indexPath.row
                cell.setChart(yAxis[indexPath.row], values: xAxis[indexPath.row])
            }
//        let newView = UIView(frame: CGRectMake(200, 10, 100, 50))
//        cell.contentView.addSubview(newView)
//        cell.detailTextLabel?.text = (users[indexPath.row]["isConnected"] as! Bool) ? "Online" : "Offline"
//        cell.detailTextLabel?.textColor = (users[indexPath.row]["isConnected"] as! Bool) ? UIColor.greenColor() : UIColor.redColor()
        
        
        return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 133.0
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        index = indexPath.row
        print("cell selected")
        self.performSegueWithIdentifier("detailDashboardSegue", sender: nil)
        
    }

    
}

private extension DashboardViewController {
    
    func requestHealthKitAuthorization() {
        let dataTypesToRead = NSSet(objects: healthKitManager.quantityType[0], healthKitManager.quantityType[1], healthKitManager.quantityType[2], healthKitManager.quantityType[3] )
        healthKitManager.healthStore?.requestAuthorizationToShareTypes(nil, readTypes: dataTypesToRead as? Set<HKObjectType>, completion: { [unowned self] (success, error) in
            if success {
                self.runQueries { (success) -> Void in
                    if success {
                        // do second task if success
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tblView.reloadData()
                            self.tblView.hidden = false
                        })
                    }
                }
                
            } else {
                print(error!.description)
            }
            })
    }
    

    func runQueries( completion: (success: Bool) -> Void) {

        self.query(0, min: false){ (success) -> Void in
            if success {
                self.xAxis.append(self.xAxisTemp)
                self.yAxis.append(self.yAxisTemp)
                self.stats.append(self.total)
                self.total = 0.0
                self.xAxisTemp = []
                self.yAxisTemp = []
                
                self.query(1, min: false){ (success) -> Void in
                    if success {
                        self.xAxis.append(self.xAxisTemp)
                        self.yAxis.append(self.yAxisTemp)
                        self.stats.append(self.total)
                        self.total = 0.0
                        self.xAxisTemp = []
                        self.yAxisTemp = []
                        
                        self.query(2, min: false){ (success) -> Void in
                            if success {
                                self.xAxis.append(self.xAxisTemp)
                                self.yAxis.append(self.yAxisTemp)
                                self.stats.append(self.total)
                                self.total = 0.0
                                self.xAxisTemp = []
                                self.yAxisTemp = []
                                
                                self.query(3, min: false){ (success) -> Void in
                                    if success {
                                        self.yAxis.append(self.yAxisTemp)
                                        self.yAxisTemp = []
                                        
                                        self.query(3, min: true){ (success) -> Void in
                                            if success {
//                                                self.yAxis.append(self.yAxisTemp)
                                                self.yAxisTemp = []
                                                
                                                completion(success: true)
                                            }
                                        }
                                    }
                                }

                            }
                        }
                    }
                }
            }
        }
    }

    func query(i: Int, min: Bool, completion: (success: Bool) -> Void) {
        let quantityType = healthKitManager.quantityType[i]
        
        //interval set by a day
        let interval = NSDateComponents()
        interval.day = 1
        
        let calendar = NSCalendar.currentCalendar()
        
        // Set the anchor date to Monday at 12:00 a.m.
        let anchorComponents = calendar.components([.Day, .Month, .Year, .Weekday], fromDate: NSDate())
        
        let offset = (7 + anchorComponents.weekday - 2) % 7
        anchorComponents.day -= offset
        anchorComponents.hour = 0
        
        guard let anchorDate = calendar.dateFromComponents(anchorComponents) else {
            fatalError("*** unable to create a valid date from the given components ***")
        }
        
        let predicate: NSPredicate = HKSampleQuery.predicateForSamplesWithStartDate(NSDate.distantPast(), endDate: NSDate(), options: HKQueryOptions.None)
        
        var query = HKStatisticsCollectionQuery(quantityType: quantityType as! HKQuantityType,
                                                quantitySamplePredicate: predicate,
                                                options: .CumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        if( i == 3 && min == true){
            query = HKStatisticsCollectionQuery(quantityType: quantityType as! HKQuantityType,
                                                    quantitySamplePredicate: predicate,
                                                    options: .DiscreteMin,
                                                    anchorDate: anchorDate,
                                                    intervalComponents: interval)
        }
        else if( i == 3 && min == false){
            query = HKStatisticsCollectionQuery(quantityType: quantityType as! HKQuantityType,
                                                quantitySamplePredicate: predicate,
                                                options: .DiscreteMax,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        }
        

        // Set the results handler
        query.initialResultsHandler = {
            query, results, error in
        
            guard let statsCollection = results else {
                // Perform proper error handling here
                fatalError("*** An error occurred while calculating the statistics: \(error?.localizedDescription) ***")
            }
            
            let endDate = NSDate()
            
            guard let startDate = calendar.dateByAddingUnit(.Day, value: -6, toDate: endDate, options: []) else {
                fatalError("*** Unable to calculate the start date ***")
            }
            
            statsCollection.enumerateStatisticsFromDate(startDate, toDate: endDate) { [unowned self] statistics, stop in
                
                if(i != 3){
                    if let quantity = statistics.sumQuantity() {
                        let date = statistics.startDate
                        let value = quantity.doubleValueForUnit(self.healthKitManager.units[i] as! HKUnit)
                        
                        self.xAxisTemp.append(value)
                        self.total += value
                        
                        let myComponents = calendar.components(.Weekday, fromDate: date)
                        self.yAxisTemp.append(self.weekdays[myComponents.weekday])
                        print(self.weekdays[myComponents.weekday])
                        print(value)
                    }
                }
                else if (i == 3 && min == false){
                    if let quantity = statistics.maximumQuantity() {
                        let date = statistics.startDate
                        let value = quantity.doubleValueForUnit(self.healthKitManager.units[i] as! HKUnit)
                        
                        self.xAxisMin.append(value)
                         if ((self.min > value || self.min == 0.0) && (value > 0)) {
                            self.min = value
                        }
                        
                        let myComponents = calendar.components(.Weekday, fromDate: date)
                        self.yAxisTemp.append(self.weekdays[myComponents.weekday])
                        print(self.weekdays[myComponents.weekday])
                        print(value)
                    }
                }
                else if (i == 3 && min == true){
                    if let quantity = statistics.minimumQuantity() {
                        let value = quantity.doubleValueForUnit(self.healthKitManager.units[i] as! HKUnit)
                        
                        self.xAxisMax.append(value)
                        print(value)
                        
                        if self.max < value{
                            self.max = value
                        }
                        
                    }
                }
            }
             completion(success: true)
        }
        
        healthKitManager.healthStore!.executeQuery(query)
    }
    
    
    
    
    //    func queryStepsSum() {
    //        let sumOption = HKStatisticsOptions.CumulativeSum
    //        let statisticsSumQuery = HKStatisticsQuery(quantityType: healthKitManager.stepsCount!, quantitySamplePredicate: nil, options: sumOption) { [unowned self] (query, result, error) in
    //            if let sumQuantity = result?.sumQuantity() {
    ////                let headerView = self.tableView.dequeueReusableCellWithIdentifier(self.totalStepsCellIdentifier) as UITableViewCell
    //                let numberOfSteps = Int(sumQuantity.doubleValueForUnit(self.healthKitManager.stepsUnit))
    ////                headerView.textLabel.text = "\(numberOfSteps) total"
    ////                self.tableView.tableHeaderView = headerView
    //                print("Number of steps: ")
    //                print(numberOfSteps)
    //            }
    ////            self.activityIndicator.stopAnimating()
    //        }
    //        healthKitManager.healthStore?.executeQuery(statisticsSumQuery)
    //    }
    
    //    func querySteps() {
    //        let sampleQuery = HKSampleQuery(sampleType: healthKitManager.stepsCount!,
    //                                        predicate: nil,
    //                                        limit: 100,
    //                                        sortDescriptors: nil)
    //        { [unowned self] (query, results, error) in
    //            if let results = results as? [HKQuantitySample] {
    //                self.steps = results
    ////                self.tableView.reloadData()
    //            }
    ////            self.activityIndicator.stopAnimating()
    //        }
    //        healthKitManager.healthStore?.executeQuery(sampleQuery)
    //    }
}




//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier(stepCellIdentifier) as UITableViewCell
//        let step = steps[indexPath.row]
//        let numberOfSteps = Int(step.quantity.doubleValueForUnit(healthKitManager.stepsUnit))
//        cell.textLabel.text = "\(numberOfSteps) steps"
//        cell.detailTextLabel?.text = dateFormatter.stringFromDate(step.startDate)
//        return cell
//    }


