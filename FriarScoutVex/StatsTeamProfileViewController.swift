//
//  StatsTeamProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/12/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class StatsTeamProfileViewController: HasTeamViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tieLabel: UILabel!
    @IBOutlet var lossesLabel: UILabel!
    @IBOutlet var winningsLabel: UILabel!
    @IBOutlet var lostAverageLabel: UILabel!
    @IBOutlet var lostInQualsAverageLabel: UILabel!
    @IBOutlet var awardsTable: UITableView!
   
    override func viewDidLoad() {
        self.awardsTable.delegate = self
        self.awardsTable.dataSource = self
        self.tieLabel.text = "\(self.team.tieMatchCount)"
        self.winningsLabel.text = "\(self.team.winMatchCount) -"
        self.lossesLabel.text = "\(self.team.lostMatchCount) -"
        if self.team.lostMatchCount != 0 {
            self.lostAverageLabel.text = "\(self.team.lostMatchScoreSum/self.team.lostMatchCount)"
        }
        if self.team.lostMatchQualsCount != 0 {
            self.lostInQualsAverageLabel.text = "\(self.team.lostMatchQualsSum/self.team.lostMatchQualsCount)"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.awardsTable.reloadData()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Awards"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("AwardCell") as! AwardCell
        
        var a: Award = self.team.awards.objectAtIndex(indexPath.row) as! Award
        cell.awardNameLabel.text = a.award
        cell.compNameLabel.text = a.comp
        println(a.award)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.team.awards.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
