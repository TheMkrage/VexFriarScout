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
    
    @IBOutlet var rankingLabel: UILabel!
    @IBOutlet var averageLabel: UILabel!
    @IBOutlet var lowestScoreLabel: UILabel!
    @IBOutlet var highestScoreLabel: UILabel!
    @IBOutlet var spPointsLabel: UILabel!
    @IBOutlet var compLabel: UILabel!
    
    var wins = 0
    var losses = 0
    var ties = 0
    
    func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
    func alert(header:String!, withMemo memo:String!, withButtonText buttonText:String!) {
        let alertController = UIAlertController(title: header, message:
            memo, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion:  { () -> Void in
            
        })
    }

    
    override func viewDidLoad() {
        let center = view.center
        let bounds = CGRect(x: center.x, y: 200, width: self.view.frame.width - 16, height: 65)
        // Create CAShapeLayerS
        let chartRect = CAShapeLayer()
        chartRect.bounds = bounds
        chartRect.position = CGPoint(x: center.x, y: 172)
        self.view.layer.addSublayer(chartRect)
        // 1
        chartRect.backgroundColor = UIColor.darkGrayColor().CGColor
        chartRect.cornerRadius = 5
        
        let leftDivider = CAShapeLayer()
        leftDivider.bounds = CGRect(x: self.view.frame.width * (1/4), y: 172, width: 5, height: 55)
        leftDivider.position = CGPoint(x: self.view.frame.width * (1/4), y: 172)
        self.view.layer.addSublayer(leftDivider)
        leftDivider.backgroundColor = UIColor.whiteColor().CGColor
        leftDivider.cornerRadius = 5
        
        let rightDivider = CAShapeLayer()
        rightDivider.bounds = CGRect(x: self.view.frame.width * (3/4), y: 172, width: 5, height: 55)
        rightDivider.position = CGPoint(x: self.view.frame.width * (3/4), y: 172)
        self.view.layer.addSublayer(rightDivider)
        rightDivider.backgroundColor = UIColor.whiteColor().CGColor
        rightDivider.cornerRadius = 5

        let midDivider = CAShapeLayer()
        midDivider.bounds = CGRect(x: self.view.frame.width * (2/4), y: 172, width: 5, height: 55)
        midDivider.position = CGPoint(x: self.view.frame.width * (2/4), y: 172)
        self.view.layer.addSublayer(midDivider)
        midDivider.backgroundColor = UIColor.whiteColor().CGColor
        midDivider.cornerRadius = 5
        
        self.matchesTable.dataSource = self
        self.matchesTable.delegate = self
        self.compLabel.text = self.comp.name

        matches = comp.matches
        self.matchesTable.reloadData()
        self.spPointsLabel.text = "\(comp.getSPAverage())"
        self.highestScoreLabel.text = "\(comp.highestScore)"
        self.lowestScoreLabel.text = "\(comp.lowestScore)"
        if comp.matchCount != 0 {
            self.averageLabel.text = "\(comp.sumOfMatches/comp.matchCount)"
        }
        for m in comp.matches {
            if (m as! Match).didTeamTie(self.team.num) {
                ties++
            }else if (m as! Match).didTeamWin(self.team.num){
                wins++
            }else {
                losses++
            }
        }
        self.matchesTable.reloadData()
        self.rankingLabel.text = "\(wins) - \(losses) - \(ties)"
        
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
    @IBAction func spAvgHelp(sender: AnyObject) {
        alert("SP AVG", withMemo: "Unlike on the Team Profile, this SP Avg represents the average amount of SP Points \(self.team.num) scored per match.", withButtonText: "Fascinating!")
    }
    

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 0:
            return "Qualification"
        case 1:
            return "Quarterfinals"
        case 2:
            return "Semi-finals"
        case 3:
            return "Finals"
        default:
            return "ERROR"
        }
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
        dest.comp.compID = self.comp.compID
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("MatchCell") as! MatchTableCell
        var m: Match
        switch (indexPath.section) {
        case 0:
            m = self.comp.quals.objectAtIndex(indexPath.row) as! Match
        case 1:
            m = self.comp.qf.objectAtIndex(indexPath.row) as! Match
        case 2:
            m = self.comp.sf.objectAtIndex(indexPath.row) as! Match
        case 3:
            m = self.comp.finals.objectAtIndex(indexPath.row) as! Match
        default:
            m = self.matches.objectAtIndex(indexPath.row) as! Match
        }
        
        cell.contentView.addSubview(CircleView(frame: CGRectMake(10, 14, 60, 60), innerColor: UIColor.lightGrayColor().CGColor, rimColor: UIColor.lightGrayColor().CGColor, text: m.name, font: UIFont(name: "HelveticaNeue-UltraLight", size: 24)!))
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
            cell.backgroundColor = Colors.colorWithHexString("#f0f0f0")
        }else {
            cell.backgroundColor = UIColor.whiteColor()
        }

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0:
            return self.comp.quals.count
        case 1:
            return self.comp.qf.count
        case 2:
            return self.comp.sf.count
        case 3:
            return self.comp.finals.count
        default:
            return 0
        }

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.comp.finals.count != 0 {
            return 4
        }else if self.comp.sf.count != 0 {
            return 3
        }else if self.comp.qf.count != 0 {
            return 2
        }
        return 1
    }
}