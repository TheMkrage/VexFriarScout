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
        self.title = "Team \(self.team.num)"
        self.awardsTable.delegate = self
        self.awardsTable.dataSource = self
        
        self.updateTheLabels()
           }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Team \(self.team.num)"
        self.awardsTable.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.title = "Team \(self.team.num)"
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
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompeitionProfile") as! UITabBarController
        // Set the title of the menuViewController
        vc.title = (self.team.awards.objectAtIndex(indexPath.row) as! Award).comp as String
        // Destintation ViewController, set team
        let dest: CompetitionForTeamProfile = vc.viewControllers?.first as! CompetitionForTeamProfile
        var comp:Competition! = Competition()
        for var i: Int = 0; i < self.team.competitions.count; i++ {
            var c: Competition = self.team.competitions.objectAtIndex(i) as! Competition
            if c.name == (self.team.awards.objectAtIndex(indexPath.row) as! Award).comp as String {
                comp = c
            }
        }
        //comp.name = (self.team.awards.objectAtIndex(indexPath.row) as! Award).comp as String
        dest.team = self.team
        dest.comp = comp
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("AwardCell") as! AwardCell
        
        var a: Award = self.team.awards.objectAtIndex(indexPath.row) as! Award
        cell.awardNameLabel.text = a.award
        cell.compNameLabel.text = a.comp
        if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = self.colorWithHexString("#f0f0f0")
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
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (count(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
