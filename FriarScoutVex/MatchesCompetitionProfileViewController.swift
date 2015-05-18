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
        /*self.highestScoreLabel.text = "\(comp.highestScore)"
        self.lowestScoreLabel.text = "\(comp.lowestScore)"*/
        
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "matches"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("MatchCell") as! MatchTableCell
        
        
        var m: Match = self.matches.objectAtIndex(indexPath.row) as! Match
        println("hdgs\(m)")
        cell.matchNameLabel.text = m.name
        cell.redTeam1Label.text = m.red1
        cell.redTeam2Label.text = m.red2
        cell.redTeam3Label.text = m.red3
        cell.blueTeam1Label.text = m.blue1
        cell.blueTeam2Label.text = m.blue2
        cell.blueTeam3Label.text = m.blue3
        cell.redScoreLabel.text = m.redScore
        cell.blueScoreLabel.text = m.blueScore
        
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matches.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
