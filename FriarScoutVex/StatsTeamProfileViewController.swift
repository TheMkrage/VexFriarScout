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
    @IBOutlet var winningsQualLabel: UILabel!
    @IBOutlet var lossesQualLabel: UILabel!
    @IBOutlet var tieQualLabel: UILabel!
    @IBOutlet var awardsTable: UITableView!
   
    override func viewDidLoad() {
        self.awardsTable.delegate = self
        self.awardsTable.dataSource = self
        // Overall Record
        self.tieLabel.text = "\(self.team.tieMatchCount)"
        self.winningsLabel.text = "\(self.team.winMatchCount) -"
        self.lossesLabel.text = "\(self.team.lostMatchCount) -"
        // Qual Record
        self.tieQualLabel.text = "\(self.team.tieMatchQualsCount)"
        self.winningsQualLabel.text = "\(self.team.winMatchQualsCount) -"
        self.lossesQualLabel.text = "\(self.team.lostMatchQualsCount) -"
        
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
        /*let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompeitionProfile") as! UITabBarController
        // Set the title of the menuViewController
        vc.title = "\(self.team.competitions.objectAtIndex(indexPath.row).name as String)"
        // Destintation ViewController, set team
        let dest: CompetitionForTeamProfile = vc.viewControllers?.first as! CompetitionForTeamProfile
        var comp:Competition! = Competition()
        comp = self.team.competitions.objectAtIndex(indexPath.row) as! Competition
        var t: Team! = Team()
        team.num = self.title
        dest.team = team
        dest.comp = comp
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)*/
        
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
