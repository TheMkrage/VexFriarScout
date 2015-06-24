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
    @IBOutlet var awardsTable: UITableView!
   
    override func viewDidLoad() {
        println("\(self.team.num)")
        self.awardsTable.delegate = self
        self.awardsTable.dataSource = self
        
        
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
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.team.awards.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
