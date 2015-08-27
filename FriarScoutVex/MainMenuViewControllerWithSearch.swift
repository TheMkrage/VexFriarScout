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
    
    var searchResults:[SearchResults] = []
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
    
    struct SearchResults {
        var name: String!
        var additionalInfo: String!
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
            if error != nil{
                println(error?.localizedDescription)
                // Alert the user and bring them back to the main menu
                let alertController = UIAlertController(title: "Oh no! An Error!", message:
                    error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                
            }else {
                for cur in objects as! [PFObject] {
                    var s: Skills = Skills()
                    s.rank = cur["rank"] as! String
                    s.team = cur["team"] as! String
                    s.score = cur["score"] as! String
                    self.robotSkills.addObject(s)
                }
                var previousScore = -1
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
        }
        
        query = PFQuery(className:"ps")
        query.whereKey("season", equalTo:"Skyrise")
        query.limit = 10
        query.orderByDescending("score")
        query.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if error != nil{
                println(error?.localizedDescription)
                // Alert the user and bring them back to the main menu
                let alertController = UIAlertController(title: "Oh no! An Error!", message:
                    error!.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                
            }else{
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
                    
                    // (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as! MainMenuTableCell).tableView.reloadData()
                }
            }
        }
    }
    
    func updateSearchWithNewString(str:String!) {
        println(str)
        var query = PFQuery(className:"Teams")
        query.limit = 10
        query.whereKey("num", hasPrefix: str)
        var arrayOfTeams = query.findObjects() as! [PFObject]
        self.searchResults = []
        for x in arrayOfTeams {
            var curResults = SearchResults(name: (x["num"] as! String), additionalInfo: x["name"] as! String)
            self.searchResults.append(curResults)
        }
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
            self.updateSearchWithNewString(searchString)
            dispatch_async(dispatch_get_main_queue()) {
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }
        }
        return true
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
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
            self.updateInternalCell(cardCellsRows.myTeam)
        }
        
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
    
    func moveToFavorites() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("fav") as! UITabBarController
        vc.title = "Favorite"
        // Destintation ViewController, set season
        let dest: TeamBookmarksViewController = vc.viewControllers?.first as! TeamBookmarksViewController
        dest.title = "Team Favorites"
        (vc.viewControllers?.last as! CompetitionBookmarkController).title = "Team Competitions"
        // Present Main Menu
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    func updateInternalCell(row:NSInteger) {

        //for var i = self.tableView.
        if let cell = (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0))) as? MainMenuTableCell {
                (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as! MainMenuTableCell).tableView.reloadData()
        }else {
            updateInternalCell(row)
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.isEqual(self.tableView) {
            switch indexPath.row {
            case cardCellsRows.myTeam:
                self.moveToTeamProfile(self.myTeam.num)
            case cardCellsRows.favorites:
                self.moveToFavorites()
            case cardCellsRows.rs:
                self.moveToSkills()
            case cardCellsRows.ps:
                self.moveToSkills()
            default:
                println("NOPE")
            }
        }else {
            
            if tableView.isEqual(self.searchDisplayController?.searchResultsTableView) {
                self.moveToTeamProfile(self.searchResults[indexPath.row].name)
            }else if let title:String = (tableView.superview?.superview?.superview as! MainMenuTableCell).titleLabel.text{
                switch title {
                case "My Team":
                    self.moveToTeamProfile(self.myTeam.num)
                case "Favorites":
                    self.moveToTeamProfile((self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Num") as! String)
                case "Robot Skills":
                    self.moveToTeamProfile((self.robotSkills.objectAtIndex(indexPath.row) as! Skills).team)
                case "Programming Skills":
                    self.moveToTeamProfile((self.programmingSkills.objectAtIndex(indexPath.row) as! Skills).team)
                default:
                    println("WHAT")
                }
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
            cell.backView.backgroundColor = Colors.colorWithHexString("F0F0F0")
            cell.tableView.backgroundColor = Colors.colorWithHexString("F0F0F0")
            //cell.backgroundColor = Colors.colorWithHexString("F0F0F0")
            switch indexPath.row  {
            case cardCellsRows.myTeam:
                cell.titleLabel.text = "My Team"
                cell.titleLabel.backgroundColor = Colors.colorWithHexString("366999")
                var teamCircle:CircleView = CircleView(frame: CGRectMake(30, 30, 90, 90))
                cell.addSubview(teamCircle)
            case cardCellsRows.favorites:
                cell.titleLabel.text = "Favorites"
                cell.titleLabel.backgroundColor = Colors.colorWithHexString("BBA020")
            case cardCellsRows.rs:
                cell.titleLabel.text = "Robot Skills"
                cell.titleLabel.backgroundColor = Colors.colorWithHexString("33774C")
            case cardCellsRows.ps:
                cell.titleLabel.text = "Programming Skills"
                cell.titleLabel.backgroundColor = Colors.colorWithHexString("8F423E")
            default:
                cell.titleLabel.text = "ERROR"
            }
            return cell
        }else {
            if tableView == self.searchDisplayController!.searchResultsTableView {
                var cell = (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! MainMenuTableCell).tableView.dequeueReusableCellWithIdentifier("searchResultsCell") as! TeamBookmarkCell
                cell.teamLabel.text = self.searchResults[indexPath.row].name
                cell.seasonLabel.text = self.searchResults[indexPath.row].additionalInfo
                
                return cell
                // PUT SEARCH RESULTS ROW HERE
            }else if let title:String = (tableView.superview?.superview?.superview as! MainMenuTableCell).titleLabel.text {
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
            return (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! MainMenuTableCell).tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            println("POWER OF RA")
            return self.searchResults.count
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