//
//  TeamProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/9/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class TeamProfileViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var competitionsTable: UITableView!

    var competitions: NSMutableArray!
    var dates: NSMutableArray!
    var loc: NSMutableArray!
    
    var team: NSString! = ""
    override func viewWillAppear(animated: Bool) {
        competitions = NSMutableArray()
        self.dates = NSMutableArray()
        self.loc = NSMutableArray()
        let ref = Firebase(url: "https://vexscout.firebaseio.com/teams/\(team)/comps")
        ref.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot:FDataSnapshot!) -> Void in
            println("Begin!")
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
            println(rest.value["date"])
                
            self.competitions.addObject(rest.value["name"]as! String)
            self.dates.addObject(rest.value["date"]as! String)
        self.loc.addObject(rest.value["loc"]as! String)
                
            self.competitionsTable.reloadData()
            }
        
        })
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
        if !(self.competitions != nil) {
            return 0
        }
        return competitions.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Competitions"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Sorts numerically
        //sorted = self.sortArray(teams)
        
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("CompetitionCell") as! CompetitionTableCell
        cell.nameLabel.text = self.competitions.objectAtIndex(indexPath.row) as? String
         cell.dateLabel.text = self.dates.objectAtIndex(indexPath.row) as? String
         cell.LocationLabel.text = self.loc.objectAtIndex(indexPath.row)as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompeitionProfile") as! UITabBarController
        // Set the title of the menuViewController
        vc.title = "\(competitions.objectAtIndex(indexPath.row))"
        // Destintation ViewController, set team
        let dest: CompetitionForTeamProfile = vc.viewControllers?.first as! CompetitionForTeamProfile
        dest.competition = competitions.objectAtIndex(indexPath.row)as! String
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
    }

}
