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
    override func viewDidLoad() {
        self.matchesTable.dataSource = self
        self.matchesTable.delegate = self
        matches = comp.matches
        println(matches)
        self.matchesTable.reloadData()
        self.highestScoreLabel.text = "\(comp.highestScore)"
        self.lowestScoreLabel.text = "\(comp.lowestScore)"
        
    }
    
    
    @IBAction func highestButton(sender: AnyObject) {
        var index:NSIndexPath = NSIndexPath(forRow: self.comp.highestRowNum, inSection: 0)
        self.matchesTable.scrollToRowAtIndexPath(index, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
    @IBAction func lowestButton(sender: AnyObject) {
        var index:NSIndexPath = NSIndexPath(forRow: self.comp.lowestRowNum, inSection: 0)
        self.matchesTable.scrollToRowAtIndexPath(index, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
    }
   
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Matches"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("MatchCell") as! MatchTableCell
        
        
        var m: Match = self.matches.objectAtIndex(indexPath.row) as! Match
       // println("hdgs\(m)")
        cell.matchNameLabel.text = m.name
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
            cell.backgroundColor = self.colorWithHexString("#e0e0e0")
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
