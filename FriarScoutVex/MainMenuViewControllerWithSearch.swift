//
//  MainMenuViewControllerWithSearch.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 8/16/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class MainMenuViewControllerWithSearch: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var robotSkills:NSMutableArray = NSMutableArray()
    var programmingSkills:NSMutableArray = NSMutableArray()
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        self.getData()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    func getData() {

        // Robot Skills
        var query = PFQuery(className:"rs")
        query.whereKey("season", equalTo:"Skyrise")
        query.limit = 10
        query.orderByDescending("score")
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            for cur in objects as! [PFObject] {
                var s: Skills = Skills()
                s.rank = cur["rank"] as! String
                s.team = cur["team"] as! String
                s.score = cur["score"] as! String
                self.robotSkills.addObject(s)
            }

            (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as! MainMenuTableCell).tableView.reloadData()
        }
        
        query = PFQuery(className:"ps")
        query.whereKey("season", equalTo:"Skyrise")
        query.limit = 10
        query.orderByDescending("score")
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            for cur in objects as! [PFObject] {
                var s: Skills = Skills()
                s.rank = cur["rank"] as! String
                s.team = cur["team"] as! String
                s.score = cur["score"] as! String
                self.programmingSkills.addObject(s)
            }
           // (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as! MainMenuTableCell).tableView.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.isEqual(self.tableView) {
            println("SELECT")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.isEqual(self.tableView) {
            var cell = tableView.dequeueReusableCellWithIdentifier("CardCell") as! MainMenuTableCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.setUp()
            cell.tableView.delegate = self
            cell.tableView.dataSource = self
            switch indexPath.row  {
            case 0:
                cell.titleLabel.text = "My Team"
            case 1:
                cell.titleLabel.text = "Favorites"
            case 2:
                cell.titleLabel.text = "Robot Skills"
                println("loaded rs")
            case 3:
                cell.titleLabel.text = "Programming Skills"
                println("loaded ps")
            default:
                cell.titleLabel.text = "ERROR"
            }
            return cell
        }else {
            if let title:String = (tableView.superview?.superview?.superview as! MainMenuTableCell).titleLabel.text {
                switch title {
                case "My Team":
                    return tableView.dequeueReusableCellWithIdentifier("statCell") as! StatisticsTableCell
                case "Robot Skills":
                    println("rs: \(indexPath.row)")
                    var cell = tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
                    cell.rankLabel.text = (self.robotSkills.objectAtIndex(indexPath.row) as! Skills).rank
                    cell.teamLabel.text = (self.robotSkills.objectAtIndex(indexPath.row) as! Skills).team
                    cell.scoreLabel.text = (self.robotSkills.objectAtIndex(indexPath.row) as! Skills).score
                    return cell
                case "Programming Skills":
                    println("ps: \(indexPath.row)")
                    var cell = tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
                    cell.rankLabel.text = (self.programmingSkills.objectAtIndex(indexPath.row) as! Skills).rank
                    cell.teamLabel.text = (self.programmingSkills.objectAtIndex(indexPath.row) as! Skills).team
                    cell.scoreLabel.text = (self.programmingSkills.objectAtIndex(indexPath.row) as! Skills).score
                    return cell
                default:
                    return tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
                }
            }
            return tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !tableView.isEqual(self.tableView) {
            if let title:String = (tableView.superview?.superview?.superview as! MainMenuTableCell).titleLabel.text {
                switch title {
                case "My Team":
                    return 3
                case "Favorites":
                    return 0
                case "Robot Skills":
                    return self.robotSkills.count
                case "Programming Skills":
                    return self.programmingSkills.count
                default:
                    return 0
                }
            }
            return 0
        }else {
            return 5
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}