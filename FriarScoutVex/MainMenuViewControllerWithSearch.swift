//
//  MainMenuViewControllerWithSearch.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 8/16/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class MainMenuViewControllerWithSearch: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate, UISearchDisplayDelegate {
    
    var myTeam: Team = Team()
    var curSeason = "Skyrise"
    
    var bookmarks = NSMutableArray()
    
    var statistics: [Statistic] = []
    
    var robotSkills:NSMutableArray = NSMutableArray()
    var programmingSkills:NSMutableArray = NSMutableArray()
    
    struct cardCellsRows {
        static let myTeam = 0
        static let favorites = 1
        static let rs = 2
        static let ps = 3
    }
    
    struct defaultsKeys {
        static let myTeam = "myTeam"
    }
    
    struct Statistic {
        var stat:String
        var value:String
    }
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        self.getData()
        println("finsihed that method")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    
    
    func getData() {
        // Bookmarks 
        self.getBookmarks()
        
        // Team Information
        let defaults = NSUserDefaults.standardUserDefaults()
        if let stringOne = defaults.valueForKey(defaultsKeys.myTeam) as? String {
            self.myTeam.num = stringOne
            self.myTeam.season = self.curSeason
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
                self.myTeam = Team.loadTeam(self.myTeam)
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateMyTeamTable()
                }
            }
        }
        
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
            var previousScore = 0
            var curStreak = false
            var count = 0
            var curRank = "T-1"
            for var i = 0; i < self.robotSkills.count; i = i + 1{
                var cur = self.robotSkills.objectAtIndex(i) as! Skills
                if cur.score.toInt() == previousScore {
                    println("hello \(i)")
                    if curStreak {
                        cur.rank = curRank
                    }else {
                        curStreak = true
                        cur.rank = "T-\(i)"
                        (self.robotSkills.objectAtIndex(i - 1) as! Skills).rank = "T-\(i)"
                        curRank = "T-\(i)"
                    }
                }else {
                    curStreak = false
                }
                previousScore = cur.score.toInt()!
            }
            self.updateInternalCell(cardCellsRows.rs)
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
            // Fix the tie things
            var previousScore = 0
            var curStreak = false
            var count = 0
            var curRank = "T-1"
            for var i = 0; i < self.programmingSkills.count; i = i + 1{
                var cur = self.programmingSkills.objectAtIndex(i) as! Skills
                if cur.score.toInt() == previousScore {
                    println("hello \(i)")
                    if curStreak {
                        cur.rank = curRank
                    }else {
                        curStreak = true
                        cur.rank = "T-\(i)"
                        (self.programmingSkills.objectAtIndex(i - 1) as! Skills).rank = "T-\(i)"
                        curRank = "T-\(i)"
                    }
                }else {
                    curStreak = false
                }
                previousScore = cur.score.toInt()!
            }
            // (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as! MainMenuTableCell).tableView.reloadData()
        }
    }
    
    func updateMyTeamTable() {
        // Overall Record
        var tie = "\(self.myTeam.tieMatchCount)"
        var win = "\(self.myTeam.winMatchCount) - "
        var loss = "\(self.myTeam.lostMatchCount) - "
        var record = Statistic(stat: "Record", value: "\(win)\(loss)\(tie)")
        self.statistics.append(record)
        var highScore = Statistic(stat: "High Score", value: "\(self.myTeam.highestScore)")
        self.statistics.append(highScore)
        self.updateInternalCell(cardCellsRows.myTeam)
        println("got team")
    }
    
    func getBookmarks() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let curBookmarks = defaults.valueForKey("Bookmarks") as? NSArray {
            self.bookmarks.addObjectsFromArray(curBookmarks as [AnyObject])
        }
        if let curBookmarks = defaults.valueForKey("Bookmarks Comp") as? NSArray {
            self.bookmarks.addObjectsFromArray(curBookmarks as [AnyObject])
        }
    }
    
    // Give it a team, it moves to their profile
    func moveToTeamProfile(team: String!) {
        var team1 = team
        if team.isEmpty {
            team1 = "3309B"
        }
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! UITabBarController
        // Destintation ViewController, set team
        let dest: OverviewTeamProfileViewController = vc.viewControllers?.first as! OverviewTeamProfileViewController
        var team2: Team! = Team()
        team2.num = team1.uppercaseString
        team2.season = self.curSeason as String
        dest.team = team2
        // Set the title of the menuViewController
        vc.title = "Team \(team1)"
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    func moveToSkills() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("skills") as! UITabBarController
        vc.title = "Skills"
        // Destintation ViewController, set season
        let dest: SkillsViewController = vc.viewControllers?.first as! SkillsViewController
        dest.title = "Robot Skills"
        (vc.viewControllers?.last as! ProgrammingSkillsViewController).title = "Programming Skills"
        (vc.viewControllers?.last as! ProgrammingSkillsViewController).season = self.curSeason as String
        dest.season = self.curSeason as String
        // Present Main Menu
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    func updateInternalCell(row:NSInteger) {
        (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as! MainMenuTableCell).tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.isEqual(self.tableView) {
            switch indexPath.row {
            case cardCellsRows.myTeam:
                self.moveToTeamProfile(self.myTeam.num)
            case cardCellsRows.rs:
                self.moveToSkills()
            case cardCellsRows.ps:
                self.moveToSkills()
            default:
                println("NOPE")
            }
            
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
            case cardCellsRows.myTeam:
                cell.titleLabel.text = "My Team"
            case cardCellsRows.favorites:
                cell.titleLabel.text = "Favorites"
            case cardCellsRows.rs:
                cell.titleLabel.text = "Robot Skills"
                println("loaded rs")
            case cardCellsRows.ps:
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
                    var cell = tableView.dequeueReusableCellWithIdentifier("statCell") as! StatisticsTableCell
                    cell.statisticLabel.text = self.statistics[indexPath.row].stat
                    cell.valueLabel.text = self.statistics[indexPath.row].value
                    return cell
                case "Favorites":
                    var cell = tableView.dequeueReusableCellWithIdentifier("favTeamCell") as! TeamBookmarkCell
                    if let team = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Num") as? String {
                        cell.teamLabel.text = team
                    }else if let compName = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Name") as? String {
                        cell.teamLabel.text = compName
                    }
                    cell.seasonLabel.text = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Season") as? String
                    return cell
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
        if tableView == self.searchDisplayController!.searchResultsTableView {
            println("POWER OF RA")
            return 2
        }else if !tableView.isEqual(self.tableView) {
            if let title:String = (tableView.superview?.superview?.superview as! MainMenuTableCell).titleLabel.text {
                switch title {
                case "My Team":
                    return self.statistics.count
                case "Favorites":
                    return self.bookmarks.count
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
            return 4
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}