//
//  CompetitionForTeamProfile.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/21/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class CompetitionForTeamProfile: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var comp: Competition!
    var team: Team!
    var matches: NSMutableArray!
    @IBOutlet var matchesTable: UITableView!
    
    @IBOutlet var averageLabel: UILabel!
    @IBOutlet var lowestScoreLabel: UILabel!
    @IBOutlet var highestScoreLabel: UILabel!
    @IBOutlet var spPointsLabel: UILabel!
    @IBOutlet var compLabel: UILabel!
    
    func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        self.matchesTable.dataSource = self
        self.matchesTable.delegate = self
        self.compLabel.text = self.comp.name
        var homeButton: UIBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: "goHome")
        self.tabBarController?.navigationItem.rightBarButtonItem = homeButton

        matches = comp.matches
        self.matchesTable.reloadData()
        self.spPointsLabel.text = "\(comp.getSPAverage())"
        self.highestScoreLabel.text = "\(comp.highestScore)"
        self.lowestScoreLabel.text = "\(comp.lowestScore)"
        if comp.matchCount != 0 {
            self.averageLabel.text = "\(comp.sumOfMatches/comp.matchCount)"
        }
    }
    
    @IBAction func highestBut(sender: AnyObject) {
        var index:NSIndexPath = NSIndexPath(forRow: self.comp.highestRowNum, inSection: 0)
        self.matchesTable.scrollToRowAtIndexPath(index, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        self.matchesTable.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.Top);

    }
    @IBAction func lowestBut(sender: AnyObject) {
        var index:NSIndexPath = NSIndexPath(forRow: self.comp.lowestRowNum, inSection: 0)
        self.matchesTable.scrollToRowAtIndexPath(index, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        self.matchesTable.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.Top);

    }
    

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Matches"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    @IBAction func showFullComp(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompFullProfile") as! UITabBarController
        // Set the title of the menuViewController
        vc.title = "\(self.comp.name)"
        // Destintation ViewController, set team
        let dest: OverviewCompetitionProfileViewController = vc.viewControllers?.first as! OverviewCompetitionProfileViewController
        dest.name = self.comp.name
        dest.season = self.comp.season
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("MatchCell") as! MatchTableCell
        var m: Match = self.matches.objectAtIndex(indexPath.row) as! Match
        cell.matchNameLabel.text = m.name as String
        cell.redTeam1Label.text = m.red1 as String
        cell.redTeam2Label.text = m.red2 as String
        cell.redTeam3Label.text = m.red3 as String
        cell.blueTeam1Label.text = m.blue1 as String
        cell.blueTeam2Label.text = m.blue2 as String
        cell.blueTeam3Label.text = m.blue3 as String
        cell.redScoreLabel.text = m.redScore as String
        cell.blueScoreLabel.text = m.blueScore as String
        
        let underlineAttribute = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        let boldAttribute = [NSStrokeWidthAttributeName: 7]
        let underlineAttributedString = NSAttributedString(string: self.team.num, attributes: underlineAttribute)
        // Find out what position the team is in
        if m.colorTeamIsOn(self.team.num).isEqualToString("red") {
            let scoreAttr:NSMutableAttributedString = NSMutableAttributedString(string: m.redScore as String, attributes: underlineAttribute)
            if m.didTeamWin(self.team.num) {
                scoreAttr.addAttribute(NSStrokeWidthAttributeName, value: 7, range: NSRange(location: 0, length: m.redScore.length))
            }else if m.didTeamTie(self.team.num) {
                scoreAttr.addAttribute(NSStrokeWidthAttributeName, value: 7, range: NSRange(location: 0, length: m.redScore.length))
                let opScoreAttr = NSMutableAttributedString(string: m.blueScore as String, attributes: boldAttribute)
                cell.blueScoreLabel.attributedText = opScoreAttr
            }else{
                let opScoreAttr = NSMutableAttributedString(string: m.blueScore as String, attributes: boldAttribute)
                cell.blueScoreLabel.attributedText = opScoreAttr
            }
            cell.redScoreLabel.attributedText = scoreAttr
            if m.red1.isEqualToString(self.team.num) {
                cell.redTeam1Label.attributedText = underlineAttributedString
            }else  if m.red2.isEqualToString(self.team.num) {
                cell.redTeam2Label.attributedText = underlineAttributedString
            }else  if m.red3.isEqualToString(self.team.num) {
                cell.redTeam3Label.attributedText = underlineAttributedString
            }
        }else if m.colorTeamIsOn(self.team.num).isEqualToString("blue") {
            let scoreAttr:NSMutableAttributedString = NSMutableAttributedString(string: m.blueScore as String, attributes: underlineAttribute)
            if m.didTeamWin(self.team.num) {
                scoreAttr.addAttribute(NSStrokeWidthAttributeName, value: 7, range: NSRange(location: 0, length: m.blueScore.length))
            }else if m.didTeamTie(self.team.num) {
                scoreAttr.addAttribute(NSStrokeWidthAttributeName, value: 7, range: NSRange(location: 0, length: m.blueScore.length))
                let opScoreAttr = NSMutableAttributedString(string: m.redScore as String, attributes: boldAttribute)
                cell.redScoreLabel.attributedText = opScoreAttr
            }else {
                let opScoreAttr = NSMutableAttributedString(string: m.redScore as String, attributes: boldAttribute)
                cell.redScoreLabel.attributedText = opScoreAttr
            }
            cell.blueScoreLabel.attributedText = scoreAttr
            if m.blue1.isEqualToString(self.team.num) {
                cell.blueTeam1Label.attributedText = underlineAttributedString
            }else  if m.blue2.isEqualToString(self.team.num) {
                cell.blueTeam2Label.attributedText = underlineAttributedString
            }else  if m.blue3.isEqualToString(self.team.num) {
                cell.blueTeam3Label.attributedText = underlineAttributedString
            }
        }
        if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = self.colorWithHexString("#f0f0f0")
        }else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matches.count
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
