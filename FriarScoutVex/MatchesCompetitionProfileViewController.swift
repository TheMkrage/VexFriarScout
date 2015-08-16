//
//  MatchesCompetitionProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/17/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class MatchesCompetitionProfileViewController: HasCompetitionViewController, UITableViewDelegate, UITableViewDataSource {
    var matches: NSMutableArray!
    @IBOutlet var matchesTable: UITableView!
    @IBOutlet var lowestScoreLabel: UILabel!
    @IBOutlet var highestScoreLabel: UILabel!
    @IBOutlet var avgLabel: UILabel!
    
    override func viewDidLoad() {
        let center = view.center
        let bounds = CGRect(x: center.x, y: 20, width: self.view.frame.width - 16, height: 67)
        // Create CAShapeLayerS
        let chartRect = CAShapeLayer()
        chartRect.bounds = bounds
        chartRect.position = CGPoint(x: center.x, y: 200)
        self.view.layer.addSublayer(chartRect)
        // 1
        chartRect.backgroundColor = UIColor.darkGrayColor().CGColor
        chartRect.cornerRadius = 20

        self.matchesTable.dataSource = self
        self.matchesTable.delegate = self
        matches = comp.matches
        println(matches)
        self.matchesTable.reloadData()
        self.highestScoreLabel.text = "\(comp.highestScore)"
        self.lowestScoreLabel.text = "\(comp.lowestScore)"
        var sum = 0
        var count = 0
        for var i = 0; i < self.matches.count; i++ {
            var m: Match = self.matches.objectAtIndex(i) as! Match
            sum = sum + m.redScore.integerValue
            sum = sum + m.blueScore.integerValue
            count += 2
        }
        self.avgLabel.text = "\(sum/count)"
    }
    
    
    @IBAction func highestButton(sender: AnyObject) {
        var index:NSIndexPath = NSIndexPath(forRow: self.comp.highestRowNum, inSection: 0)
        self.matchesTable.scrollToRowAtIndexPath(index, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        self.matchesTable.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.Top);
    }
    @IBAction func lowestButton(sender: AnyObject) {
        var index:NSIndexPath = NSIndexPath(forRow: self.comp.lowestRowNum, inSection: 0)
        self.matchesTable.scrollToRowAtIndexPath(index, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        self.matchesTable.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.Top);
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
        
        let boldAttribute = [NSStrokeWidthAttributeName: 7]
        // Find out what position the team is in
        if m.colorTeamWon().isEqualToString("red") {
            let scoreAttr:NSMutableAttributedString = NSMutableAttributedString(string: m.redScore as String, attributes: boldAttribute)
            cell.redScoreLabel.attributedText = scoreAttr
        }else if m.colorTeamWon().isEqualToString("blue") {
            let scoreAttr:NSMutableAttributedString = NSMutableAttributedString(string: m.blueScore as String, attributes: boldAttribute)
            cell.blueScoreLabel.attributedText = scoreAttr
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
    }}
