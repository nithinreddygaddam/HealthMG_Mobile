//
//  BarChartDashboard.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/30/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import ChameleonFramework
import Charts

class BarChartDashboard: UIView {
    
    var yaxis = [String]()
    var rates =  [Double]()
    
    @IBOutlet weak var barChartView: BarChartView!
    
//    override init(frame: CGRect) {
//        super.init(frame:frame)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        barChartView.noDataText = "No data to load"
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.xAxis.setLabelsToSkip(0)
        barChartView.legend.enabled = false
//        barChartView.scaleYEnabled = false
//        barChartView.scaleXEnabled = false
        barChartView.pinchZoomEnabled = true
        barChartView.doubleTapToZoomEnabled = false
        barChartView.highlighter = nil
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.enabled = true
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.descriptionText = ""
        barChartView.drawValueAboveBarEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        
        setChart(yaxis, values: rates)
        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        barChartView.data = chartData
//        barChartView.isDrawValueAboveBarEnabled = false
//        barChartView.barData =
        
        
        
    }
    
    
}
