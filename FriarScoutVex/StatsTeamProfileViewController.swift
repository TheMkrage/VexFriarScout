//
//  StatsTeamProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/12/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class StatsTeamProfileViewController: HasTeamViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var lostAverageLabel: UILabel!
    @IBOutlet var lostInQualsAverageLabel: UILabel!
    @IBOutlet var lostInElimsAverageLabel: UILabel!
    @IBOutlet var wonAverageLabel: UILabel!
    @IBOutlet var wonInQualsAverageLabel: UILabel!
    @IBOutlet var wonInElimsAverageLabel: UILabel!
    @IBOutlet var overallAverageLabel: UILabel!
    @IBOutlet var overallInQualsAverageLabel: UILabel!
    @IBOutlet var overallInElimsAverageLabel: UILabel!
    @IBOutlet var awardsTable: UITableView!
    
    override func viewDidLoad() {
        self.drawBackground()
        //self.title = "Team \(self.team.num)"
        self.awardsTable.delegate = self
        self.awardsTable.dataSource = self
        
        self.updateTheLabels()
    }
    
    func drawBackground() {
        let center = view.center
        let bounds = CGRect(x: center.x, y: 110, width: self.view.frame.width - 20, height: 116)
        // Create CAShapeLayerS
        let chartRect = CAShapeLayer()
        chartRect.bounds = bounds
        chartRect.position = CGPoint(x: center.x, y: 110)
        self.view.layer.addSublayer(chartRect)
        // 1
        chartRect.backgroundColor = UIColor.darkGrayColor().CGColor
        chartRect.cornerRadius = 20

    }
    
    override func viewWillAppear(animated: Bool) {
        self.awardsTable.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }
    
    func updateTheLabels() {
        // LOST AVERAGE LABELS
        doAverageLabel(self.lostAverageLabel, count: self.team.lostMatchCount, sum: self.team.lostMatchScoreSum)
        doAverageLabel(self.lostInQualsAverageLabel, count: self.team.lostMatchQualsCount, sum: self.team.lostMatchQualsSum)
        doAverageLabel(self.lostInElimsAverageLabel, count: self.team.lostMatchCount - self.team.lostMatchQualsCount, sum: self.team.lostMatchScoreSum - self.team.lostMatchQualsSum)
        //WON AVERAGE LABELS
        doAverageLabel(self.wonAverageLabel, count: self.team.winMatchCount, sum: self.team.winMatchScoreSum)
        doAverageLabel(self.wonInQualsAverageLabel, count: self.team.winMatchQualsCount, sum: self.team.winMatchQualsSum)
        doAverageLabel(self.wonInElimsAverageLabel, count: self.team.winMatchCount - self.team.winMatchQualsCount, sum: self.team.winMatchScoreSum - self.team.winMatchQualsSum)
        //OVERALL AVERAGE LABELS
        doAverageLabel(self.overallAverageLabel, count: self.team.matchCount, sum: self.team.sumOfMatches)
        doAverageLabel(self.overallInQualsAverageLabel, count: self.team.qualCount, sum: self.team.lostMatchQualsSum + self.team.winMatchQualsSum + self.team.tieMatchQualsSum)
        doAverageLabel(self.overallInElimsAverageLabel, count: self.team.matchCount - self.team.qualCount, sum: self.team.sumOfMatches - (self.team.lostMatchQualsSum + self.team.winMatchQualsSum + self.team.tieMatchQualsSum))
    }
    
    func doAverageLabel(label:UILabel!, count: Int, sum: Int) {
        if count != 0 {
            label.text = "\(sum/count)"
        }else {
            label.text = "NA"
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Awards"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var comp:Competition! = Competition()
        for var i: Int = 0; i < self.team.competitions.count; i++ {
            var c: Competition = self.team.competitions.objectAtIndex(i) as! Competition
            if c.name == (self.team.awards.objectAtIndex(indexPath.row) as! Award).comp as String {
                comp = c
            }
        }

        if comp.date == "League" {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompFullProfile") as! UITabBarController
            // Set the title of the menuViewController
            vc.title = "\(comp.name)"
            // Destintation ViewController, set team
            let dest: OverviewCompetitionProfileViewController = vc.viewControllers?.first as! OverviewCompetitionProfileViewController
            dest.name = comp.name
            dest.season = comp.season
            dest.comp.compID = comp.compID
            // Present Profile
            self.showViewController(vc as UIViewController, sender: vc)
        }else {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompeitionProfile") as! UITabBarController
            // Set the title of the menuViewController
            vc.title = (self.team.awards.objectAtIndex(indexPath.row) as! Award).comp as String
            // Destintation ViewController, set team
            let dest: CompetitionForTeamProfile = vc.viewControllers?.first as! CompetitionForTeamProfile
                //comp.name = (self.team.awards.objectAtIndex(indexPath.row) as! Award).comp as String
            dest.team = self.team
            dest.comp = comp
            // Present Profile
            self.showViewController(vc as UIViewController, sender: vc)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("AwardCell") as! AwardCell
        var a: Award = self.team.awards.objectAtIndex(indexPath.row) as! Award
        var color:CGColor = UIColor.grayColor().CGColor
        var letter = String(Array(a.award)[0]).uppercaseString
        
        if a.award.lowercaseString.rangeOfString("skills") != nil {
            color = Colors.colorWithHexString("#FF6666").CGColor
        }else if a.award.lowercaseString.rangeOfString("champion") != nil {
            color = Colors.colorWithHexString("#80CCFF").CGColor
        }else if a.award.lowercaseString.rangeOfString("excellence") != nil {
            color = Colors.colorWithHexString("#CCB2FF").CGColor
        }else if a.award.lowercaseString.rangeOfString("tournament") != nil {
            color = Colors.colorWithHexString("#FFB280").CGColor
        }else {
            color = Colors.colorWithHexString("#99E699").CGColor
        }
        cell.contentView.addSubview(CircleView(frame: CGRectMake(10, 0, 61, 61), innerColor: color, rimColor: color, text: letter, font: UIFont(name: "HelveticaNeue-UltraLight", size: 30)!))
        cell.awardNameLabel.text = a.award
        cell.compNameLabel.text = a.comp
        if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = Colors.colorWithHexString("#f0f0f0")
        }else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.team.awards.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
