//
//  HeartRateCell.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/29/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import ChameleonFramework
import Charts

class HeartRateCell: UITableViewCell {
    
    var yaxis = [String]()
    var rates =  [Double]()
    
    @IBOutlet weak var lblStatMin: UILabel!
    @IBOutlet weak var lblStatMax: UILabel!

    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var lblAtrribute: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lineChartView.noDataText = "No data to load"
        lineChartView.xAxis.labelPosition = .Bottom
        lineChartView.xAxis.setLabelsToSkip(0)
        lineChartView.legend.enabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.pinchZoomEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.highlighter = nil
        lineChartView.rightAxis.enabled = false
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.animate(yAxisDuration: 1.5, easingOption: .EaseInOutQuart)
        lineChartView.descriptionText = ""
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.labelTextColor = FlatWatermelon()
//        lineChartView.delegate = self
        
        
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setChartData(xAxis : [String], yAxisMax : [Double], yAxisMin : [Double]) {
        // 1 - creating an array of data entries
        var yVals1 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< xAxis.count {
            yVals1.append(ChartDataEntry(value: yAxisMax[i], xIndex: i))
        }
        
        //create a data set with our array
        let set1: LineChartDataSet = LineChartDataSet(yVals: yVals1, label: "Max")
        set1.axisDependency = .Left // Line will correlate with left axis values
        set1.setColor(UIColor.flatGreenColor().colorWithAlphaComponent(0.5)) // our line's opacity is 50%
        set1.setCircleColor(UIColor.flatGreenColor()) // our circle will be dark red
        set1.lineWidth = 2.0
        set1.circleRadius = 2 // the radius of the node circle
        set1.fillAlpha = 65 / 255.0
        set1.fillColor = UIColor.flatGreenColor()
//        set1.highlightColor = UIColor.blackColor()
        set1.drawCircleHoleEnabled = true
        set1.valueTextColor = UIColor.blackColor()
        
        // min set
        var yVals2 : [ChartDataEntry] = [ChartDataEntry]()
        for i in 0 ..< xAxis.count {
            yVals2.append(ChartDataEntry(value: yAxisMin[i], xIndex: i))
        }
        
        let set2: LineChartDataSet = LineChartDataSet(yVals: yVals2, label: "Min")
        set2.axisDependency = .Left // Line will correlate with left axis values
        set2.setColor(UIColor.flatRedColor().colorWithAlphaComponent(0.5))
        set2.setCircleColor(UIColor.flatRedColor())
        set2.lineWidth = 2.0
        set2.circleRadius = 2
        set2.fillAlpha = 65 / 255.0
        set2.fillColor = UIColor.flatRedColor()
//        set2.highlightColor = UIColor.whiColor()
        set2.drawCircleHoleEnabled = true
        set2.valueTextColor = UIColor.blackColor()
        
        //create an array to store our LineChartDataSets
        var dataSets : [LineChartDataSet] = [LineChartDataSet]()
        dataSets.append(set1)
        dataSets.append(set2)
        
        //pass our months in for our x-axis label value along with our dataSets
        let data: LineChartData = LineChartData(xVals: xAxis, dataSets: dataSets)
        data.setDrawValues(false)
        
        //finally set our data
        self.lineChartView.data = data
    }
    
}
