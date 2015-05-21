//
//  AwardsCompetitionProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/17/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class AwardsCompetitionProfileViewController: HasCompetitionViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var awardTable: UITableView!
    
    override func viewDidLoad() {
        
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
        
        var a: Award = self.comp.awards.objectAtIndex(indexPath.row) as! Award
        cell.awardNameLabel.text = a.award
        cell.compNameLabel.text = a.team.num
        println(a.award)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comp.awards.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
