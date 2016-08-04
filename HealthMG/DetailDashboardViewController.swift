//
//  DetailDashboardViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/8/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import HealthKit
import ChameleonFramework

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
    var minDate: String = ""
    var maxDate: String = ""
    var count = 0.0
    var last = 0.0
    var lastDate: String = ""
    var lastMax = 0.0
    var totalMax = 0.0
    
    let attributes:[String] = ["Steps", "Distance", "Calories", "Heart Rate"]
    let colors:[UIColor] = [FlatSkyBlue(), FlatLime(), FlatYellow(), FlatWatermelon()]
    
    //constants for priods (Today, Daily, Monthly....)
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
    
    @IBOutlet weak var btnToday: UIButton!
    @IBOutlet weak var btnDaily: UIButton!
    @IBOutlet weak var btnWeekly: UIButton!
    @IBOutlet weak var btnMonthly: UIButton!
    @IBOutlet weak var btn365Days: UIButton!
    
    private let healthKitManager = HealthKitManager.sharedInstance

    @IBOutlet weak var statView1: StatView!
    @IBOutlet weak var statView2: StatView!
    @IBOutlet weak var statView3: StatView!
    @IBOutlet weak var statView4: StatView!
    var stat1: UIView!
    var stat2: UIView!
    var stat3: UIView!
    var stat4: UIView!
    
    var prev: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = attributes[index]
        // Do any additional setup after loading the view.
//                self.tabBarController?.tabBar.hidden = true
        btnDaily.backgroundColor = colors[index]
        prev =  btnDaily
        runQueries(1)
        
        stat1 = NSBundle.mainBundle().loadNibNamed("StatView", owner: self, options: nil)[0] as? UIView
        stat2 = NSBundle.mainBundle().loadNibNamed("StatView", owner: self, options: nil)[0] as? UIView
        stat3 = NSBundle.mainBundle().loadNibNamed("StatView", owner: self, options: nil)[0] as? UIView
        stat4 = NSBundle.mainBundle().loadNibNamed("StatView", owner: self, options: nil)[0] as? UIView
        
        if index != 3{
            chart = NSBundle.mainBundle().loadNibNamed("BarChartDashboard", owner: self, options: nil)[0] as? UIView
        }
        else{
            chart = NSBundle.mainBundle().loadNibNamed("LineChartDashboard", owner: self, options: nil)[0] as? UIView
        }
        
        self.chartView.addSubview(chart)
        self.chart.frame = self.chartView.bounds
        
        self.statView1.addSubview(stat1)
        self.stat1.frame = self.statView1.bounds
        self.statView2.addSubview(stat2)
        self.stat2.frame = self.statView2.bounds
        self.statView3.addSubview(stat3)
        self.stat3.frame = self.statView3.bounds
        self.statView4.addSubview(stat4)
        self.stat4.frame = self.statView4.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnToday(sender: AnyObject) {
        btnToday.backgroundColor = colors[index]
        prev.backgroundColor = FlatGrayDark()
        prev =  btnToday
        runQueries(0)
    }
    @IBAction func btnDaily(sender: AnyObject) {
        btnDaily.backgroundColor = colors[index]
        prev.backgroundColor = FlatGrayDark()
        prev =  btnDaily
        runQueries(1)
    }
    
    @IBAction func btnWeekly(sender: AnyObject) {
        btnWeekly.backgroundColor = colors[index]
        prev.backgroundColor = FlatGrayDark()
        prev =  btnWeekly
        runQueries(2)
    }
    
    @IBAction func btnMonthy(sender: AnyObject) {
        btnMonthly.backgroundColor = colors[index]
        prev.backgroundColor = FlatGrayDark()
        prev =  btnMonthly
         runQueries(3)
    }
    
    @IBAction func btn365Days(sender: AnyObject) {
        btn365Days.backgroundColor = colors[index]
        prev.backgroundColor = FlatGrayDark()
        prev =  btn365Days
        runQueries(4)
    }
    

}

private extension DetailDashboardViewController {
    
    
    func runQueries(period: Int) {
        
//        yAxis = []
//        xAxis = []
//        xAxisMin = []
//        xAxisMax = []
//        min = 0.00
//        max = 0.00
//        total = 0.00
//        count = 0.00
//        last = 0.00
//        lastMax = 0.00
//        totalMax = 0.00
        var skip = 0
        
        
        if self.index == 3{
            self.query(false, periodIndex: period){ (success) -> Void in
                if success {
                    self.query(true, periodIndex: period){ (success) -> Void in
                        if success {
                    
                            // do second task if success
                            dispatch_async(dispatch_get_main_queue(), {
                                
                                
                                switch self.period[period] {
                                case "Today":
                                    skip = self.yAxis.count / 8
                                case "Daily":
                                    skip = self.yAxis.count / 5
                                case "Weekly":
                                    skip = self.yAxis.count / 4
                                case "Monthly":
                                    skip = self.yAxis.count / 13
                                case "365 Days":
                                    skip = self.yAxis.count / 7
                                default:
                                    skip = 0
                                }
                                
                                (self.chart as! LineChartDashboard).setChartData(self.yAxis, yAxisMax: self.xAxisMax, yAxisMin : self.xAxisMin, skipLabels: skip)
                                
                                (self.stat1 as! StatView).lblType.text = "last"
                                (self.stat1 as! StatView).lblStat.text = String(self.last) + " - " + String(self.lastMax)
                                (self.stat1 as! StatView).lblDate.text = self.lastDate
                                (self.stat2 as! StatView).lblType.text = "average"
                                (self.stat2 as! StatView).lblStat.text = String(round(self.total/self.count)) + " - " + String(round(self.totalMax/self.count))
                                (self.stat2 as! StatView).lblDate.text = " "
                                (self.stat3 as! StatView).lblType.text = "min"
                                (self.stat3 as! StatView).lblStat.text = String(round(100.0 * self.min) / 100.0)
                                (self.stat3 as! StatView).lblDate.text = self.minDate
                                (self.stat4 as! StatView).lblType.text = "max"
                                (self.stat4 as! StatView).lblStat.text = String(round(100.0 * self.max) / 100.0)
                                (self.stat4 as! StatView).lblDate.text = self.maxDate

                                
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
                        
                        switch self.period[period] {
                        case "Today":
                            skip = self.yAxis.count / 8
                        case "Daily":
                            skip = self.yAxis.count / 5
                        case "Weekly":
                            skip = self.yAxis.count / 4
                        case "Monthly":
                            skip = self.yAxis.count / 13
                        case "365 Days":
                            skip = self.yAxis.count / 7
                        default:
                            skip = 0
                        }
                        
                        (self.chart as! BarChartDashboard).color = self.index
                        (self.chart as! BarChartDashboard).setChart(self.yAxis, values: self.xAxis, skipLabels: skip)
                        (self.stat1 as! StatView).lblType.text = "last"
                        (self.stat1 as! StatView).lblStat.text = String(round(100.0 * self.last) / 100.0)
                        (self.stat1 as! StatView).lblDate.text = self.lastDate
                        (self.stat2 as! StatView).lblType.text = "average"
                        (self.stat2 as! StatView).lblStat.text = String(round(100.0 * self.total/self.count) / 100.0)
                        (self.stat2 as! StatView).lblDate.text = " "
                        (self.stat3 as! StatView).lblType.text = "min"
                        (self.stat3 as! StatView).lblStat.text = String(round(100.0 * self.min) / 100.0)
                        (self.stat3 as! StatView).lblDate.text = self.minDate
                        (self.stat4 as! StatView).lblType.text = "max"
                        (self.stat4 as! StatView).lblStat.text = String(round(100.0 * self.max) / 100.0)
                        (self.stat4 as! StatView).lblDate.text = self.maxDate
                        
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
        
        let anchorComponents = calendar.components([.Day, .Month, .Year, .Weekday], fromDate: NSDate())
        
//        let offset = (7 + anchorComponents.weekday - 2) % 7
//        anchorComponents.day -= offset
        anchorComponents.hour = 0
//        anchorComponents.minute = 0
        
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
            var startDate: NSDate
            
            
            switch self.period[periodIndex] {
            case "Today":
                startDate = calendar.dateByAddingUnit(.Hour, value: -5, toDate: endDate, options: [])!
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
            
            if(self.yAxis != []){
                self.yAxis = []
                self.xAxis = []
                self.xAxisMin = []
                self.xAxisMax = []
                self.min = 0.00
                self.max = 0.00
                self.total = 0.00
                self.count = 0.00
                self.last = 0.00
                self.lastMax = 0.00
                self.totalMax = 0.00
            }
            
            statsCollection.enumerateStatisticsFromDate(startDate, toDate: endDate) { [unowned self] statistics, stop in
                
                let startDate = statistics.startDate
                let endDate = statistics.endDate
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

                
                if(self.index != 3){
                    if let quantity = statistics.sumQuantity() {
                        
                        let value = quantity.doubleValueForUnit(self.healthKitManager.units[self.index] as! HKUnit)
                        
                        self.xAxis.append(value)
                        self.total += value
                        self.count += 1
                        
                        if ((self.min > value || self.min == 0.0) && (value > 0)) {
                            self.min = value
                            self.minDate = dateStr
                        }
                        
                        if self.max < value{
                            self.max = value
                            self.maxDate = dateStr
                        }
                        
                        if(value > 0.0){
                            self.last = value
                            self.lastDate = dateStr
                        }
                        
                        self.yAxis.append(dateStr)
                    }
                }
                else if (self.index == 3 && min == true){
                    if let quantity = statistics.minimumQuantity() {
                        let value = quantity.doubleValueForUnit(self.healthKitManager.units[self.index] as! HKUnit)

                        self.total += value
                        self.count += 1
                        
                        self.xAxisMin.append(value)
                        if ((self.min > value || self.min == 0.0) && (value > 0)) {
                            self.min = value
                            self.minDate = dateStr
                        }
                        
                        if(value > 0.0){
                            self.last = value
                            self.lastDate = dateStr
                            self.maxDate = dateStr
                        }
                        
                        self.yAxis.append(dateStr)
                    }
                }
                else if (self.index == 3 && min == false){
                    if let quantity = statistics.maximumQuantity() {
                        let value = quantity.doubleValueForUnit(self.healthKitManager.units[self.index] as! HKUnit)
                        
                        self.totalMax += value
                        
                        self.xAxisMax.append(value)
                        
                        if(value > 0.0){
                            self.lastMax = value
                        }
                        
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
}
