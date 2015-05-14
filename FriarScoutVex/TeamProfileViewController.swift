//
//  TeamProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/9/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class TeamProfileViewController: HasTeamViewController,UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var competitionsTable: UITableView!
    
    
    override func viewWillAppear(animated: Bool) {
        self.competitionsTable.reloadData()
    }
    override func viewDidLoad() {
        
        //set delegates and datasources
        self.competitionsTable.delegate = self
        self.competitionsTable.dataSource = self
        
           }
    
    //TABLE STUFF
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // In case competitions
        if !(self.team.competitions != nil) {
            return 0
        }
        return self.team.competitions.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Competitions"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Sorts numerically
        //sorted = self.sortArray(teams)
        
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("CompetitionCell") as! CompetitionTableCell
        cell.nameLabel.text = (self.team.competitions.objectAtIndex(indexPath.row) as! Competition).name as String
        cell.dateLabel.text = (self.team.competitions.objectAtIndex(indexPath.row) as! Competition).date as String
        cell.LocationLabel.text = (self.team.competitions.objectAtIndex(indexPath.row) as! Competition).loc as String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompeitionProfile") as! UITabBarController
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
        self.showViewController(vc as UIViewController, sender: vc)
        /*
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompetitionProfile") as! CompetitionForTeamProfile
        // Set the title of the menuViewController
        vc.title = "\(competitions.objectAtIndex(indexPath.row).name as String)"
        // Destintation ViewController, set team
        var comp:Competition! = Competition()
        comp = competitions.objectAtIndex(indexPath.row) as! Competition
        var t: Team! = Team()
        team.num = self.title
        vc.team = team
        vc.comp = comp
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)*/
    }
    
}
