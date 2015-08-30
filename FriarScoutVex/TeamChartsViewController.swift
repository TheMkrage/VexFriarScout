//
//  TeamChartsViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 8/29/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class TeamChartsViewController: HasTeamViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    
    var averageChart: LineChart = LineChart()
    
    override func viewDidLoad() {
        self.team.orderCompetitions()
        addAverageChart()
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 720)
    }
    
    func addAverageChart() {
        var xLabels: [String] = []
        var averageData: [CGFloat] = []
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "mm-dd-yyyy"
        for ctemp in self.team.competitions {
            var comp: Competition = ctemp as! Competition
            if comp.date != "League" {
                var datePart:[String] = comp.date.componentsSeparatedByString("-")
                var simplifiedDate:String = "\(datePart[1])-\(datePart[2])"
                if comp.matches.count != 0 {
                    xLabels.append(simplifiedDate)
                    
                    averageData.append(CGFloat((comp.sumOfQuals)/comp.quals.count))
                    println(CGFloat((comp.sumOfQuals)/comp.quals.count))
                }
            }
        }
        
        // simple line with custom x axis labels
        
        
        averageChart = LineChart()
        averageChart.frame = CGRect(x: 0, y: 45, width: self.view.frame.width, height: 200)
        averageChart.animation.enabled = true
        averageChart.area = true
        averageChart.x.labels.visible = true
        averageChart.x.grid.count = CGFloat(xLabels.count)
        averageChart.y.grid.count = 5
        averageChart.x.labels.values = xLabels
        averageChart.y.labels.visible = true
        averageChart.addLine(averageData)
        averageChart.setTranslatesAutoresizingMaskIntoConstraints(false)
        //lineChart.delegate = self
        self.scrollView.addSubview(averageChart)
    }
}
