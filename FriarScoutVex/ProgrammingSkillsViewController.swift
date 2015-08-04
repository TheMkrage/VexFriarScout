//
//  SkillsViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 6/18/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class ProgrammingSkillsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Season for URL
    var season:String! = ""
    var ps:NSMutableArray = NSMutableArray()
    // Array table uses
    var curSkills:NSMutableArray = NSMutableArray()
    // Table
    @IBOutlet var skillsTable: UITableView!

    
    override func viewDidLoad() {
        var myTeamButton: UIBarButtonItem = UIBarButtonItem(title: "My Team", style: .Plain, target: self, action: "myTeam")
        self.tabBarController?.navigationItem.rightBarButtonItem = myTeamButton
        self.skillsTable.delegate = self
        self.skillsTable.dataSource = self
        println("LOADING:")
        self.loadSkills()
    }
    
    func myTeam() {
        var team: String! = ""
        var foundAt = -1
        let defaults = NSUserDefaults.standardUserDefaults()
        if let stringOne = defaults.valueForKey("myTeam") as? String {
            team = stringOne
        }
        for (var i = 0; i < self.ps.count; i++) {
            if  (ps.objectAtIndex(i) as! Skills).team == team {
                foundAt = (ps.objectAtIndex(i) as! Skills).rank.toInt()!
            }
        }
        if foundAt == -1 {
            
            let alertController = UIAlertController(title: "I'm so sorry", message:
                "It appears that your team is not in the top 50 :(  Keep trying and check back later!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "EEK!", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                
            })
            
        }else {
            var index:NSIndexPath = NSIndexPath(forRow: foundAt, inSection: 0)
            self.skillsTable.scrollToRowAtIndexPath(index, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
            self.skillsTable.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.Top)
        }
    }

    override func viewWillAppear(animated: Bool) {
        var myTeamButton: UIBarButtonItem = UIBarButtonItem(title: "My Team", style: .Plain, target: self, action: "myTeam")
        self.tabBarController?.navigationItem.rightBarButtonItem = myTeamButton
        self.skillsTable.reloadData()
    }
    
    // Gets and stores skills data in two arrays (ps and rs)
    func loadSkills() {
        // Programming Skills
        var ref1: Firebase = Firebase(url:"https://vexscoutcompetitions.firebaseio.com/\(self.season)/ps")
        ref1.queryLimitedToFirst(50).observeEventType(.ChildAdded, withBlock: { snapshot in
            var s:Skills = Skills()
            s.rank = snapshot.value["rank"] as! String
            s.team = snapshot.value["team"] as! String
            s.score = snapshot.value["score"] as! String
            self.ps.addObject(s)
            self.curSkills = self.ps
            self.skillsTable.reloadData()
        })
    }
    
    // Table Datasource and Delegate
    // Creates cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:SkillsCell = tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
        var s: Skills = self.curSkills.objectAtIndex(indexPath.row) as! Skills
        cell.rankLabel.text = "\(s.rank)."
        cell.scoreLabel.text = "\(s.score)"
        cell.teamLabel.text = "\(s.team)"
        if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = Colors.colorWithHexString("#eecbcb")
        }else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Programming Skills"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.curSkills.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! UITabBarController
        // Destintation ViewController, set team
        let dest: OverviewTeamProfileViewController = vc.viewControllers?.first as! OverviewTeamProfileViewController
        var team2: Team! = Team()
        team2.num = (self.curSkills.objectAtIndex(indexPath.row) as! Skills).team
        team2.season = self.season as String
        dest.team = team2
        // Set the title of the menuViewController
        vc.title = "Team \(team2.num)"
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}