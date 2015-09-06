//
//  SkillsViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 6/18/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class SkillsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Season for URL
    var curSeason:String! = ""
    // Arrays for data
    var rs:NSMutableArray = NSMutableArray()
    // Table
    @IBOutlet var skillsTable: UITableView!
    
    override func viewDidLoad() {
        self.loadSkills()
        self.skillsTable.delegate = self
        self.skillsTable.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        var myTeamButton: UIBarButtonItem = UIBarButtonItem(title: "My Team", style: .Plain, target: self, action: "myTeam")
        self.tabBarController?.navigationItem.rightBarButtonItem = myTeamButton
        self.skillsTable.reloadData()
    }
    
    // Gets and stores skills data in two arrays (ps and rs)
    func loadSkills() {
        var query = PFQuery(className:"rs")
        query.whereKey("season", equalTo:self.curSeason)
        query.limit = 50
        query.orderByDescending("score")
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if error != nil{
                println(error?.localizedDescription)
                // Alert the user and bring them back to the main menu
                if (error!.localizedDescription as NSString).containsString("application performed") {
                    let alertController = UIAlertController(title: "Too many requests!", message:
                        "Try again in a few minutes! We are refreshing our data right now!", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok :(", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }else {
                    let alertController = UIAlertController(title: "Oh no! An Error!", message:
                        error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }
                
            }else {
                for cur in objects as! [PFObject] {
                    var s: Skills = Skills()
                    s.rank = cur["rank"] as! String
                    s.team = cur["team"] as! String
                    s.score = cur["score"] as! NSInteger
                    self.rs.addObject(s)
                }
                var previousScore = -1
                var curStreak = false
                var count = 0
                var curRank = "T-1"
                for var i = 0; i < self.rs.count; i = i + 1{
                    var cur = self.rs.objectAtIndex(i) as! Skills
                    if cur.score == previousScore {
                        if curStreak {
                            cur.rank = curRank
                        }else {
                            curStreak = true
                            cur.rank = "T-\(i)"
                            (self.rs.objectAtIndex(i - 1) as! Skills).rank = "T-\(i)"
                            curRank = "T-\(i)"
                        }
                    }else {
                        curStreak = false
                    }
                    previousScore = cur.score
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.skillsTable.reloadData()
                }
            }
        }
    }
    
    // Table Datasource and Delegate
    // Creates cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:SkillsCell = tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
        var s: Skills = self.rs.objectAtIndex(indexPath.row) as! Skills
        cell.rankLabel.text = "\(s.rank)."
        cell.scoreLabel.text = "\(s.score)"
        cell.teamLabel.text = "\(s.team)"
        println("LOADING CELL")
        if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = Colors.colorWithHexString("#c5e2ec")
        }else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! UITabBarController
        // Destintation ViewController, set team
        let dest: OverviewTeamProfileViewController = vc.viewControllers?.first as! OverviewTeamProfileViewController
        var team2: Team! = Team()
        team2.num = (self.rs.objectAtIndex(indexPath.row) as! Skills).team
        team2.season = self.curSeason as String
        dest.team = team2
        // Set the title of the menuViewController
        vc.title = "Team \(team2.num)"
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.rs.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Robot Skills"
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
}
