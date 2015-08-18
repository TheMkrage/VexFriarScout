//
//  MainMenuViewControllerWithSearch.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 8/16/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class MainMenuViewControllerWithSearch: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var robotSkills:NSMutableArray = NSMutableArray()
    var programmingSkills:NSMutableArray = NSMutableArray()
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.isEqual(self.tableView) {
            // Creates cell and sets title to team num
            var array: NSMutableArray = NSMutableArray()
            var s:Skills = Skills()
            s.rank = "rank"
            s.team = "team"
            s.score = "score"
            array.addObject(s)
            var cell = tableView.dequeueReusableCellWithIdentifier("CardCell") as! MainMenuTableCell
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
            case 3:
                cell.titleLabel.text = "Programming Skills"
            default:
                cell.titleLabel.text = "ERROR"
            }
            return cell
        }else {
            if let title:String = (tableView.superview?.superview?.superview as! MainMenuTableCell).titleLabel.text {
                switch title {
                    case "My Team":
                        return tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
                    case "Robot Skills":
                        var cell = tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
                        cell.rankLabel.text = (self.robotSkills.objectAtIndex(indexPath.row) as! Skills).rank
                        cell.teamLabel.text = (self.robotSkills.objectAtIndex(indexPath.row) as! Skills).team
                        cell.scoreLabel.text = (self.robotSkills.objectAtIndex(indexPath.row) as! Skills).score
                        return cell
                    case "Programming Skills":
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
        return 5
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}