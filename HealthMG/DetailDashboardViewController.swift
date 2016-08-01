//
//  DetailDashboardViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/8/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import HealthKit

class DetailDashboardViewController: UIViewController {

    var index = 0
    var yAxis:[String]  = []
    var xAxis:[Double]  = []
    var xAxisMin:[Double]  = []
    var xAxisMax:[Double]  = []
    var stats:[Double]  = []
    var total = 0.0
    var min = 0.0
    var max = 0.0
    
    let attributes:[String] = ["Steps", "Distance", "Calories", "Heart Rate"]
    
    //constants for priods (Today, Daily, Monthly....)
//    let period: [[String]] = [["Daily", 1, 3], ["Today", 1, 3], ["Weekly", 1, 3],["Monthly", 1 , 3], ["365 Days", 1, 3]]
    let period: [String] = ["Today" , "Daily", "Weekly", "Monthly", "365 Days"]
    
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
    
    let months = [
        "nil",
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
    ]
    
    @IBOutlet weak var chartView: UIView!
    var chart: UIView!
    
    private let healthKitManager = HealthKitManager.sharedInstance

    @IBOutlet weak var statView1: StatView!
    @IBOutlet weak var statView2: StatView!
    @IBOutlet weak var statView3: StatView!
    @IBOutlet weak var statView4: StatView!
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
                self.tabBarController?.tabBar.hidden = true
        runQueries(1)
        
        if index != 3{
            chart = NSBundle.mainBundle().loadNibNamed("BarChartDashboard", owner: self, options: nil)[0] as? UIView
        }
        else{
            chart = NSBundle.mainBundle().loadNibNamed("LineChartDashboard", owner: self, options: nil)[0] as? UIView
        }
        
        self.chartView.addSubview(chart)
        self.chart.frame = self.chartView.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func btnToday(sender: AnyObject) {
        runQueries(0)
    }
    @IBAction func btnDaily(sender: AnyObject) {
        runQueries(1)
    }
    
    @IBAction func btnWeekly(sender: AnyObject) {
        runQueries(2)
    }
    
    @IBAction func btnMonthy(sender: AnyObject) {
         runQueries(3)
    }
    
    @IBAction func btn365Days(sender: AnyObject) {
        runQueries(4)
    }
    

}

private extension DetailDashboardViewController {
    
//    func requestHealthKitAuthorization() {
//        let dataTypesToRead = NSSet(objects: healthKitManager.quantityType[0], healthKitManager.quantityType[1], healthKitManager.quantityType[2], healthKitManager.quantityType[3] )
//        healthKitManager.healthStore?.requestAuthorizationToShareTypes(nil, readTypes: dataTypesToRead as? Set<HKObjectType>, completion: { [unowned self] (success, error) in
//            if success {
//                self.runQueries { (success) -> Void in
//                    if success {
//                        // do second task if success
//                        dispatch_async(dispatch_get_main_queue(), {
////                            self.tblView.reloadData()
////                            self.tblView.hidden = false
//                        })
//                    }
//                }
//                
//            } else {
//                print(error!.description)
//            }
//            })
//    }
    
    
    func runQueries(period: Int) {
        
        yAxis = []
        xAxis = []
        xAxisMin = []
        xAxisMax = []
        
        if self.index == 3{
            self.query(false, periodIndex: period){ (success) -> Void in
                if success {
                    self.query(true, periodIndex: period){ (success) -> Void in
                        if success {
                    
                            // do second task if success
                            dispatch_async(dispatch_get_main_queue(), {
                                (self.chart as! LineChartDashboard).setChartData(self.yAxis, yAxisMax: self.xAxisMax, yAxisMin : self.xAxisMin)
                            })
                        }
                    }
                }
            }
        }else{
            self.query(false, periodIndex: period){ (success) -> Void in
                if success {
                    // do second task if success
                    dispatch_async(dispatch_get_main_queue(), {
                        (self.chart as! BarChartDashboard).setChart(self.yAxis, values: self.xAxis)
                    })
                }
            }
        }
        
    }
    
    
    func query(min: Bool, periodIndex: Int, completion: (success: Bool) -> Void) {
        let quantityType = healthKitManager.quantityType[index]
        
        
        //interval set by the period
        let interval = NSDateComponents()
        switch period[periodIndex] {
        case "Today":
            interval.minute = 10
        case "Daily":
            interval.day = 1
        case "Weekly":
            interval.day = 7
        case "Monthly":
            interval.month = 1
        case "365 Days":
            interval.day = 1
        default:
            interval.day = 1
        }
        
        
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
        
        if( index == 3 && min == true){
            query = HKStatisticsCollectionQuery(quantityType: quantityType as! HKQuantityType,
                                                quantitySamplePredicate: predicate,
                                                options: .DiscreteMin,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        }
        else if( index == 3 && min == false){
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
            let startDate: NSDate
            
            
            switch self.period[periodIndex] {
            case "Today":
                startDate = calendar.dateByAddingUnit(.Hour, value: -23, toDate: endDate, options: [])!
            case "Daily":
                startDate = calendar.dateByAddingUnit(.Day, value: -31, toDate: endDate, options: [])!
            case "Weekly":
                startDate = calendar.dateByAddingUnit(.Day, value: -195, toDate: endDate, options: [])!
            case "Monthly":
                startDate = calendar.dateByAddingUnit(.Month, value: -11, toDate: endDate, options: [])!
            case "365 Days":
                startDate = calendar.dateByAddingUnit(.Day, value: -364, toDate: endDate, options: [])!
            default:
                startDate = calendar.dateByAddingUnit(.Day, value: -6, toDate: endDate, options: [])!
            }
            
            
            statsCollection.enumerateStatisticsFromDate(startDate, toDate: endDate) { [unowned self] statistics, stop in
                
                if(self.index != 3){
                    if let quantity = statistics.sumQuantity() {
                        let startDate = statistics.startDate
                        let endDate = statistics.endDate
                        let value = quantity.doubleValueForUnit(self.healthKitManager.units[self.index] as! HKUnit)
                        
                        self.xAxis.append(value)
                        self.total += value
                        var dateStr: String
                        
                        switch self.period[periodIndex] {
                        case "Today":
                            var myComponents = calendar.components(.Hour, fromDate: startDate)
                            dateStr = String(myComponents.hour) + ":"
                            myComponents = calendar.components(.Minute, fromDate: startDate)
                            dateStr += String(myComponents.minute)
                        case "Daily":
                            var myComponents = calendar.components(.Weekday, fromDate: startDate)
                            dateStr = self.weekdays[myComponents.weekday] + " "
                            myComponents = calendar.components(.Month, fromDate: startDate)
                            dateStr += self.months[myComponents.month] + " "
                            myComponents = calendar.components(.Day, fromDate: startDate)
                            dateStr += String(myComponents.day)
                        case "Weekly":
                            var myComponents = calendar.components(.Month, fromDate: startDate)
                            dateStr = self.months[myComponents.month] + " "
                            myComponents = calendar.components(.Day, fromDate: startDate)
                            dateStr += String(myComponents.day)
                            myComponents = calendar.components(.Month, fromDate: endDate)
                            dateStr += "-" + self.months[myComponents.month] + " "
                            myComponents = calendar.components(.Day, fromDate: endDate)
                            dateStr += String(myComponents.day)
                        case "Monthly":
                            let myComponents = calendar.components(.Month, fromDate: startDate)
                            dateStr = self.months[myComponents.month]
                        case "365 Days":
                            var myComponents = calendar.components(.Month, fromDate: startDate)
                            dateStr = self.months[myComponents.month] + " "
                            myComponents = calendar.components(.Day, fromDate: startDate)
                            dateStr += String(myComponents.day)
                        default:
                            var myComponents = calendar.components(.Month, fromDate: startDate)
                            dateStr = self.months[myComponents.month] + " "
                            myComponents = calendar.components(.Day, fromDate: startDate)
                            dateStr += String(myComponents.day)
                        }
                        
                        self.yAxis.append(dateStr)
                    }
                }
                else if (self.index == 3 && min == false){
                    if let quantity = statistics.maximumQuantity() {
                        let date = statistics.startDate
                        let value = quantity.doubleValueForUnit(self.healthKitManager.units[self.index] as! HKUnit)
                        
                        self.xAxisMin.append(value)
                        if self.min > value{
                            self.min = value
                        }
                        
                        let myComponents = calendar.components(.Weekday, fromDate: date)
                        self.yAxis.append(self.weekdays[myComponents.weekday])
                        print(self.weekdays[myComponents.weekday])
                        print(value)
                    }
                }
                else if (self.index == 3 && min == true){
                    if let quantity = statistics.minimumQuantity() {
                        let value = quantity.doubleValueForUnit(self.healthKitManager.units[self.index] as! HKUnit)
                        
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
