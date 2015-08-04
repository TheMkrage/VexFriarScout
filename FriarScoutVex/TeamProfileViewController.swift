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
    
    /*override func viewDidAppear(animated: Bool) {
        self.competitionsTable.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        self.competitionsTable.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.competitionsTable.setContentOffset(CGPointMake(0, 0), animated: false)
    }*/
    
    override func viewDidLoad() {
        self.navigationItem.title = "Team \(self.team.num)"
        
        //set delegates and datasources
        self.competitionsTable.delegate = self
        self.competitionsTable.dataSource = self
        self.team.orderCompetitions()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
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
        if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = Colors.colorWithHexString("#f0f0f0")
        }else {
            cell.backgroundColor = UIColor.whiteColor()
        }

        return cell
    }
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var comp:Competition! = Competition()
        comp = self.team.competitions.objectAtIndex(indexPath.row) as! Competition
        // Make formatter
        if comp.date == "League" {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompFullProfile") as! UITabBarController
            // Set the title of the menuViewController
            vc.title = "\(comp.name)"
            // Destintation ViewController, set team
            let dest: OverviewCompetitionProfileViewController = vc.viewControllers?.first as! OverviewCompetitionProfileViewController
            dest.name = comp.name
            dest.season = comp.season
            // Present Profile
            self.showViewController(vc as UIViewController, sender: vc)
        }else {
            var formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            var cDate: NSDate = formatter.dateFromString(comp.date)!
            var dateComparisionResult:NSComparisonResult = cDate.compare(NSDate())
            if(dateComparisionResult == NSComparisonResult.OrderedDescending) {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EmptyProfile") as! EmptyCompetitionProfileViewController
                // Set the title of the menuViewController
                vc.title = "\(comp.name)"
                vc.name = comp.name
                vc.season = comp.season
                vc.comp = comp
                // Destintation ViewController, set team
                
                // Present Profile
                self.showViewController(vc as UIViewController, sender: vc)
                
            }else {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompeitionProfile") as! UITabBarController
                // Set the title of the menuViewController
                vc.title = "Team \(self.team.num)"
                // Destintation ViewController, set team
                let dest: CompetitionForTeamProfile = vc.viewControllers?.first as! CompetitionForTeamProfile
                
                //comp.season = self.team.season
                dest.team = self.team
                dest.comp = comp
                // Present Profile
                self.showViewController(vc as UIViewController, sender: vc)
            }
        }
    }
}
