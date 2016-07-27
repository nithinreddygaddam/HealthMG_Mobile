//
//  UserCell.swift
//  weebyChat
//
//  Created by Nithin Reddy Gaddam on 5/13/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import ChameleonFramework
import Charts

class DashboardCell: UITableViewCell {
    
    var yaxis = [String]()
    var rates =  [Double]()

    @IBOutlet weak var barChartView: BarChartView!
//    @IBOutlet weak var imgBckg: UIImageView!
    @IBOutlet weak var lblStat: UILabel!
    @IBOutlet weak var lblAtrribute: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        
//        let colors:[UIColor] = [
//
//            UIColor.flatGrayColorDark(),
//
//            UIColor.flatWhiteColor()
//        ]
        
        barChartView.noDataText = "No data to load"
        barChartView.xAxis.labelPosition = .Bottom
        barChartView.xAxis.setLabelsToSkip(0)
        barChartView.legend.enabled = false
        barChartView.scaleYEnabled = false
        barChartView.scaleXEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.highlighter = nil
        barChartView.rightAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.enabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.animate(yAxisDuration: 1.5, easingOption: .EaseInOutQuart)
        barChartView.descriptionText = ""
        barChartView.drawValueAboveBarEnabled = false
        barChartView.xAxis.drawAxisLineEnabled = false
        
//        barChartView.leftAxis.axisMinValue = 0.0
//        barChartView.leftAxis.axisMaxValue = 1000.0
        
        setChart(yaxis, values: rates)
        
//        imgBckg.backgroundColor = GradientColor(.TopToBottom, frame: imgBckg.frame, colors: colors)
       
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
        let chartData = BarChartData(xVals: yaxis, dataSet: chartDataSet)
        barChartView.data = chartData
        
        
    }

    
    

}
