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
    var oprDprCcwmChart: LineChart = LineChart()
    override func viewDidLoad() {
        self.team.orderCompetitions()
        addCharts()
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 600)
    }
    
    func addCharts() {
        
        var xAverageLabels: [String] = ["start"]
        var xStatsLabels: [String] = ["start"]
        
        var averageQualsData: [CGFloat] = []
        var averageElimsData: [CGFloat] = []
        var averageData: [CGFloat] = []
        
        var oprData: [CGFloat] = []
        var dprData: [CGFloat] = []
        var ccwmData: [CGFloat] = []
        
        var highestStatValue: CGFloat = CGFloat.min // used to find the step of axis
        var lowestStatValue: CGFloat = CGFloat.max // used to find the step of axis
        var maxOPR: CGFloat = CGFloat.min
        var maxDPR: CGFloat = CGFloat.min
        var maxCCWM: CGFloat = CGFloat.min
        var avgOPR: CGFloat = 0.0
        var avgDPR: CGFloat = 0.0
        var avgCCWM: CGFloat = 0.0
        var statCount = 0
        for ctemp in self.team.competitions {
            var comp: Competition = ctemp as! Competition
            if comp.date != "League" {
                var datePart:[String] = comp.date.componentsSeparatedByString("-")
                var simplifiedDate:String = "\(datePart[1])-\(datePart[2])"
                if comp.opr != 0.0 {
                    xStatsLabels.append(simplifiedDate)
                    avgOPR += comp.opr
                    avgDPR += comp.dpr
                    avgCCWM += comp.ccwm
                    statCount++
                    if comp.opr > maxOPR {
                        maxOPR = comp.opr
                    }
                    if comp.dpr > maxDPR {
                        maxDPR = comp.dpr
                    }
                    if comp.ccwm > maxCCWM {
                        maxCCWM = comp.ccwm
                    }
                    if comp.opr < lowestStatValue {
                        lowestStatValue = comp.opr
                    }
                    if comp.dpr < lowestStatValue {
                        lowestStatValue = comp.dpr
                    }
                    if comp.ccwm < lowestStatValue {
                        lowestStatValue = comp.ccwm
                    }
                    if xStatsLabels.count == 2 {
                        println(xStatsLabels)
                        oprData.append(comp.opr)
                        dprData.append(comp.dpr)
                        ccwmData.append(comp.ccwm)
                        println(oprData)
                        println(dprData)
                        println(ccwmData)
                    }
                    oprData.append(comp.opr)
                    dprData.append(comp.dpr)
                    ccwmData.append(comp.ccwm)
                }
                if comp.quals.count != 0 {
                    xAverageLabels.append(simplifiedDate)
                    if xAverageLabels.count == 2 {
                        averageData.append(CGFloat((comp.sumOfElims + comp.sumOfQuals)/(comp.quals.count + comp.elimCount)))
                        averageQualsData.append(CGFloat((comp.sumOfQuals)/comp.quals.count))
                        if comp.elimCount != 0 {
                            averageElimsData.append(CGFloat((comp.sumOfQF + comp.sumOfSF + comp.sumOfFinals)/(comp.elimCount)))
                        }else {
                            averageElimsData.append(0)
                        }
                    }

                    if comp.elimCount != 0 {
                        averageElimsData.append(CGFloat((comp.sumOfQF + comp.sumOfSF + comp.sumOfFinals)/(comp.elimCount)))
                    }else {
                        averageElimsData.append(0)
                    }
                    averageData.append(CGFloat((comp.sumOfElims + comp.sumOfQuals)/(comp.quals.count + comp.elimCount)))
                    averageQualsData.append(CGFloat((comp.sumOfQuals)/comp.quals.count))
                }
            }
        }
        avgOPR /= CGFloat(statCount)
        avgDPR /= CGFloat(statCount)
        avgCCWM /= CGFloat(statCount)
        if maxOPR > highestStatValue {
            highestStatValue = maxOPR
        }
        if maxDPR > highestStatValue{
            highestStatValue = maxDPR
        }
        if maxCCWM > highestStatValue {
            highestStatValue = maxCCWM
        }
        
        if xAverageLabels.count > 1 {
            // Average Chart setup
            var averageTitle: UILabel = UILabel()
            averageTitle.frame = CGRectMake(0, 15, self.view.frame.width, 30)
            var attrStr = NSMutableAttributedString(string: "Average, Qual Average, Elim Average", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 18.0)!])
            attrStr.addAttribute(NSForegroundColorAttributeName, value: Colors.colorWithHexString("#9C5055"), range: NSRange(location:0,length:8))
            attrStr.addAttribute(NSForegroundColorAttributeName, value: Colors.colorWithHexString("#F5A120"), range: NSRange(location:19,length:16))
            attrStr.addAttribute(NSForegroundColorAttributeName, value: Colors.colorWithHexString("#83D6B7"), range: NSRange(location:9,length:13))
            averageTitle.attributedText = attrStr
            averageTitle.textAlignment = .Center
            //averageTitle.center = CGPoint(x: self.view.center.x, y: 50)
            self.scrollView.addSubview(averageTitle)
            averageChart = LineChart()
            averageChart.frame = CGRect(x: 15, y: 45, width: self.view.frame.width - 15, height: 200)
            averageChart.animation.enabled = true
            averageChart.area = false
            averageChart.x.labels.visible = true
            println("FDSA KISS IS COSMIC \(xAverageLabels) \(xAverageLabels.count)")
            averageChart.x.grid.count = CGFloat(xAverageLabels.count)
            averageChart.y.grid.count = 5
            averageChart.x.labels.values = xAverageLabels
            averageChart.y.labels.visible = true
            averageChart.colors = [Colors.colorWithHexString("#83D6B7"), Colors.colorWithHexString("#F5A120"), Colors.colorWithHexString("#9C5055")]
            averageChart.addLine(averageQualsData)
            averageChart.addLine(averageElimsData)
            averageChart.addLine(averageData)
            averageChart.setTranslatesAutoresizingMaskIntoConstraints(false)
            //lineChart.delegate = self
            self.scrollView.addSubview(averageChart)
        }
        
        if xStatsLabels.count > 1 {
            // Setup opr,dpr,ccwm chart
            // opr,dpr,ccwm Chart setup
            var statTitle: UILabel = UILabel()
            statTitle.frame = CGRectMake(0, 265, self.view.frame.width, 30)
            var statAttrStr = NSMutableAttributedString(string: "OPR, DPR, CCWM", attributes: [NSFontAttributeName:UIFont(name: "HelveticaNeue-Bold", size: 18.0)!])
            statAttrStr.addAttribute(NSForegroundColorAttributeName, value: Colors.colorWithHexString("#5889DB"), range: NSRange(location:0,length:5))
            statAttrStr.addAttribute(NSForegroundColorAttributeName, value: Colors.colorWithHexString("#ff00ff"), range: NSRange(location:5,length:6))
            statAttrStr.addAttribute(NSForegroundColorAttributeName, value: Colors.colorWithHexString("#FF7373"), range: NSRange(location:9,length:5))
            statTitle.attributedText = statAttrStr
            statTitle.textAlignment = .Center
            //averageTitle.center = CGPoint(x: self.view.center.x, y: 50)
            self.scrollView.addSubview(statTitle)
            oprDprCcwmChart = LineChart()
            oprDprCcwmChart.frame = CGRect(x: 15, y: 290, width: self.view.frame.width - 15, height: 200)
            oprDprCcwmChart.animation.enabled = true
            oprDprCcwmChart.area = false
            oprDprCcwmChart.x.labels.visible = true
            oprDprCcwmChart.x.grid.count = CGFloat(xStatsLabels.count)
            oprDprCcwmChart.y.grid.count = ((highestStatValue - lowestStatValue)/10)
            println( oprDprCcwmChart.y.grid.count)
            oprDprCcwmChart.x.labels.values = xStatsLabels
            oprDprCcwmChart.y.labels.visible = true
            oprDprCcwmChart.colors = [Colors.colorWithHexString("#5889DB"),Colors.colorWithHexString("#ff00ff"), Colors.colorWithHexString("#FF7373")]
            oprDprCcwmChart.addLine(oprData)
            oprDprCcwmChart.addLine(dprData)
            oprDprCcwmChart.addLine(ccwmData)
            oprDprCcwmChart.setTranslatesAutoresizingMaskIntoConstraints(false)
            var oprLabel: UILabel = UILabel()
            oprLabel.frame = CGRectMake(0, 500, self.view.frame.width, 30)
            oprLabel.font = UIFont(name: "HelveticaNeue", size: 18)
            oprLabel.text = "OPR: Max: \(maxOPR) Avg: \(avgOPR)"
            oprLabel.textColor = Colors.colorWithHexString("#5889DB")
            oprLabel.textAlignment = .Center
            self.scrollView.addSubview(oprLabel)
            var dprLabel: UILabel = UILabel()
            dprLabel.frame = CGRectMake(0, 530, self.view.frame.width, 30)
            dprLabel.font = UIFont(name: "HelveticaNeue", size: 18)
            dprLabel.text = "DPR: Max: \(maxDPR) Avg: \(avgDPR)"
            dprLabel.textColor = Colors.colorWithHexString("#ff00ff")
            dprLabel.textAlignment = .Center
            self.scrollView.addSubview(dprLabel)
            var ccwmLabel: UILabel = UILabel()
            ccwmLabel.frame = CGRectMake(0, 560, self.view.frame.width, 30)
            ccwmLabel.font = UIFont(name: "HelveticaNeue", size: 18)
            ccwmLabel.text = "CCWM: Max: \(maxCCWM) Avg: \(avgCCWM)"
            ccwmLabel.textColor = Colors.colorWithHexString("#FF7373")
            ccwmLabel.textAlignment = .Center
            self.scrollView.addSubview(ccwmLabel)
            self.scrollView.addSubview(oprDprCcwmChart)
            
        }
    }
}
