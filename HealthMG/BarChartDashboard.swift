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

class BarChartDashboard: UIView, ChartViewDelegate {
    
    var yaxis = [String]()
    var xaxis =  [Double]()
    var skipLabels = 0
    var color: Int = 0
    let colors:[UIColor] = [FlatSkyBlue(), FlatLime(), FlatYellow(), FlatWatermelon()]
    
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var markerView: BaloonMarker!

    var baloon: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        barChartView.noDataText = "No data to load"
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.legend.enabled = false
        barChartView.scaleYEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.enabled = true
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.descriptionText = ""
        barChartView.xAxis.drawAxisLineEnabled = false
        barChartView.drawValueAboveBarEnabled = false
        barChartView.xAxis.labelTextColor = FlatWhite()
        barChartView.leftAxis.labelTextColor = FlatWhite()
        barChartView.leftAxis.axisLineColor = FlatBlack()
        barChartView.xAxis.labelTextColor = FlatWhite()
        
        barChartView.delegate = self
        
        baloon = (NSBundle.mainBundle().loadNibNamed("BaloonMarker", owner: self, options: nil)[0] as? UIView)!
        markerView.addSubview(baloon)
        markerView.hidden = true
    }
    

    func setChart(dataPoints: [String], values: [Double], skipLabels: Int) {
        
        barChartView.xAxis.setLabelsToSkip(skipLabels)
        
        yaxis = dataPoints
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
        chartDataSet.colors = [colors[color]]
        let chartData = BarChartData(xVals: dataPoints, dataSet: chartDataSet)
        chartData.setDrawValues(false)
        barChartView.data = chartData
        
    }
    
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        let markerPosition = chartView.getMarkerPosition(entry: entry, highlight: highlight)
        // Adding top marker
//        (self.baloon as! BaloonMarker).lblMarker.text = "\(entry.value)"
        (self.baloon as! BaloonMarker).lblMarker.text = yaxis[entry.xIndex] + " : " + String(round(entry.value * 100.0) / 100.0 )
        (self.baloon as! BaloonMarker).center = CGPointMake(markerPosition.x, self.markerView.center.y)
        markerView.hidden = false
    }
    
    func chartValueNothingSelected(chartView: ChartViewBase) {
        markerView.hidden = true
    }
    
    
}
