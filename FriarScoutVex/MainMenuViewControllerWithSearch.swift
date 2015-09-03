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
    
    var searchID = 0
    var updatingSerach = true
    var circleAdded = false
    var myTeam: Team = Team()
    var curSeason = "NBN"
    
    var searchResults:[SearchResults] = []
    var bookmarks = NSMutableArray()
    
    var statistics: [Statistic] = []
    
    var robotSkills:NSMutableArray = NSMutableArray()
    var programmingSkills:NSMutableArray = NSMutableArray()
    
    var loadingIcon: UIActivityIndicatorView = UIActivityIndicatorView()
    
    struct cardCellsRows {
        static let myTeam = 0
        static let favorites = 1
        static let rs = 2
        static let ps = 3
    }
    
    struct SearchResults {
        var name: String!
        var additionalInfo: String!
        var isTeam: Bool!
        var comp:Competition!
    }
    
    struct defaultsKeys {
        static let myTeam = "myTeam"
    }
    
    struct Statistic {
        var stat:String
        var value:String
    }
    
    override func viewDidAppear(animated: Bool) {
        // Reload if changes in season or myTeam
        let defaults = NSUserDefaults.standardUserDefaults()
        if let stringOne = defaults.valueForKey(defaultsKeys.myTeam) as? String {
            if self.myTeam.num != stringOne || self.myTeam.season != self.curSeason{
                self.myTeam.num = stringOne
                self.myTeam.season = self.curSeason
                self.title = self.curSeason
                self.myTeam = Team()
                // Make some tables hidden and Put loading icons in their places
                self.getMainMenuCellForID("MyTeam")?.tableView.hidden = true
                self.tableView.delegate = nil
                self.tableView.dataSource = nil
                self.clearCurrentData()
                self.getData()
                self.tableView.delegate = self
                self.tableView.dataSource = self
                self.tableView.reloadData()
                self.getMainMenuCellForID("MyTeam")?.tableView.hidden = false
            }
        }
    }
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "HelveticaNeue-Thin", size: 34)!]
        var settingsButton: UIBarButtonItem = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: "goToSetting")
        self.title = self.curSeason
        self.navigationItem.rightBarButtonItem = settingsButton
        self.getData()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func clearCurrentData() {
        self.statistics = []
        self.robotSkills = NSMutableArray()
        self.programmingSkills = NSMutableArray()
        self.bookmarks = NSMutableArray()
        self.circleAdded = false;
        
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
                if let x = Team.loadTeam(self.myTeam) as Team? {
                    self.myTeam = x
                }else {
                    // Alert the user and bring them back to the main menu
                    let alertController = UIAlertController(title: "Oh no! An Error!", message:
                        "Your Team does not exist!", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
                    self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                        
                    })
                    
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.updateMyTeamTable()
                }
            }
        }
        
        // Robot Skills
        var query = PFQuery(className:"rs")
        query.whereKey("season", equalTo:self.curSeason)
        query.whereKey("rank", containedIn: ["1","2","3","4","5","6","7","8","9","T-1","T-2","T-3","T-4","T-5","T-6","T-7","T-8","T-9", "T-10", "10"])
        query.limit = 10
        query.orderByAscending("rank")
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
                    self.robotSkills.addObject(s)
                }
                var previousScore = -1
                var curStreak = false
                var count = 0
                var curRank = "T-1"
                for var i = 0; i < self.robotSkills.count; i = i + 1{
                    var cur = self.robotSkills.objectAtIndex(i) as! Skills
                    if cur.score == previousScore {
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
                    previousScore = cur.score
                }
                self.getMainMenuCellForID("RobotSkills")?.tableView.reloadData()
                //self.updateInternalCell(cardCellsRows.rs)
            }
        }
        
        query = PFQuery(className:"ps")
        query.whereKey("season", equalTo:self.curSeason)
        query.whereKey("rank", containedIn: ["1","2","3","4","5","6","7","8","9","T-1","T-2","T-3","T-4","T-5","T-6","T-7","T-8","T-9", "T-10", "10"])
        query.limit = 10
        query.orderByAscending("rank")
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
                    s.score = cur["score"] as! NSInteger
                    println(s.team)
                    self.programmingSkills.addObject(s)
                }
                // Fix the tie things
                var previousScore = 0
                var curStreak = false
                var count = 0
                var curRank = "T-1"
                for var i = 0; i < self.programmingSkills.count; i = i + 1{
                    var cur = self.programmingSkills.objectAtIndex(i) as! Skills
                    if cur.score == previousScore {
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
                    previousScore = cur.score
                    
                    self.getMainMenuCellForID("ProgrammingSkills")?.tableView.reloadData()
                }
            }
        }
    }
    
    func updateSearchWithNewString(str:String!, id:Int) {
        var query = PFQuery(className:"Teams")
        query.limit = 10
        query.whereKey("num", hasPrefix: str)
        var arrayOfTeams = query.findObjects() as! [PFObject]
        if id != self.searchID {
            return
        }
        // Find some comps
        query = PFQuery(className: "Competitions")
        query.limit = 10
        query.whereKey("name", containsString: str.capitalizedString)
        query.whereKey("season", equalTo: self.curSeason)
        if id != self.searchID {
            return
        }
        var arrayOfComps = query.findObjects() as! [PFObject]
        
        self.updatingSerach = true
        self.searchResults = []
        
        for x in arrayOfTeams {
            var curResults = SearchResults(name: (x["num"] as! String),additionalInfo: x["name"] as! String, isTeam: true, comp: nil)
            self.searchResults.append(curResults)
        }
        
        for x in arrayOfComps {
            
            var comp: Competition = Competition()
            comp.date = x["date"] as! String
            comp.name = x["name"] as! String
            comp.season = x["season"] as! String
            comp.compID = x.objectId
            var curResults = SearchResults(name: (x["name"] as! String), additionalInfo: "", isTeam: false, comp: comp)
            
            self.searchResults.append(curResults)
        }
        self.updatingSerach = false
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
            self.searchID++
            self.updateSearchWithNewString(searchString, id: self.searchID)
            dispatch_async(dispatch_get_main_queue()) {
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }
        }
        return false
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
        var events = Statistic(stat: "Events", value: "\(self.myTeam.compCount)")
        self.statistics.append(events)
        println("UPDATE MY TEAM TABLE")
        dispatch_async(dispatch_get_main_queue()) {
            //self.getMainMenuCellForID("MyTeam")!.hidden = false
            self.getMainMenuCellForID("MyTeam")?.tableView.reloadData()
        }
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
    
    func goToSetting() {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Settings") as! UISettingsViewController
        vc.curSeason = self.curSeason
        self.showViewController(vc, sender: vc)
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
        (vc.viewControllers?.last as! ProgrammingSkillsViewController).curSeason = self.curSeason as String
        dest.curSeason = self.curSeason as String
        // Present Main Menu
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    func moveToComp(comp: Competition!) {
        if comp.date == "League" {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompFullProfile") as! UITabBarController
            // Set the title of the menuViewController
            vc.title = "\(comp.name)"
            // Destintation ViewController, set team
            let dest: OverviewCompetitionProfileViewController = vc.viewControllers?.first as! OverviewCompetitionProfileViewController
            dest.name = comp.name
            dest.comp.compID = comp.compID
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
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompFullProfile") as! UITabBarController
                // Set the title of the menuViewController
                vc.title = "\(comp.name)"
                // Destintation ViewController, set team
                let dest: OverviewCompetitionProfileViewController = vc.viewControllers?.first as! OverviewCompetitionProfileViewController
                dest.name = comp.name
                dest.season = comp.season
                dest.comp.compID = comp.compID
                // Present Profile
                self.showViewController(vc as UIViewController, sender: vc)
            }
        }
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
                if (self.searchResults[indexPath.row].isTeam != nil && self.searchResults[indexPath.row].isTeam! ) {
                    self.moveToTeamProfile(self.searchResults[indexPath.row].name)
                }else {
                    self.moveToComp(self.searchResults[indexPath.row].comp)
                }
            }else if let title:String = (tableView.superview?.superview?.superview as! MainMenuTableCell).titleLabel.text{
                switch title {
                case "My Team":
                    self.moveToTeamProfile(self.myTeam.num)
                case "Favorites":
                    if let team = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Num") as? String {
                        
                        self.moveToTeamProfile(team)
                    }else if let compName = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Name") as? String {
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompFullProfile") as! UITabBarController
                        // Set the title of the menuViewController
                        
                        // Destintation ViewController, set team
                        let dest: OverviewCompetitionProfileViewController = vc.viewControllers?.first as! OverviewCompetitionProfileViewController
                        dest.name = compName
                        dest.comp.compID = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("ID") as? String
                        dest.season = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Season") as? String
                        vc.title = "\(dest.name)"
                        // Present Profile
                        self.showViewController(vc as UIViewController, sender: vc)
                    }
                    
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
    
    func getMainMenuCellForID(string:String!) -> MainMenuTableCell?{
        for var i:Int = 0; i < self.tableView.numberOfRowsInSection(0); i = i + 1 {
            if self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0))?.reuseIdentifier == string {
                return self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? MainMenuTableCell
            }
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.isEqual(self.tableView) {
            if (tableView.cellForRowAtIndexPath(indexPath) == nil)  {
                //println(cell.reuseIdentifier)
                
                //cell.backgroundColor = Colors.colorWithHexString("F0F0F0")
                switch indexPath.row  {
                case cardCellsRows.myTeam:
                    var cell = tableView.dequeueReusableCellWithIdentifier("MyTeam") as! MainMenuTableCell
                    
                    if cell.titleLabel.text == "My Team" || cell.titleLabel.text == "Title"{
                        cell.clearsContextBeforeDrawing = true
                        cell.selectionStyle = UITableViewCellSelectionStyle.None
                        cell.setUp()
                        cell.tableView.delegate = self
                        cell.tableView.dataSource = self
                        
                        cell.backView.backgroundColor = Colors.colorWithHexString("F0F0F0")
                        cell.tableView.backgroundColor = Colors.colorWithHexString("F0F0F0")
                        cell.titleLabel.text = "My Team"
                        cell.titleLabel.backgroundColor = Colors.colorWithHexString("366999")
                        var teamCircle:CircleView = CircleView(frame: CGRectMake(25, 20, 90, 90), text: self.myTeam.numOnly,bottom: self.myTeam.letterOnly, innerColor: UIColor.blackColor().CGColor, rimColor: UIColor.grayColor().CGColor)
                        cell.layer.shadowOffset = CGSizeMake(15, 15);
                        cell.layer.shadowColor = UIColor.blackColor().CGColor;
                        cell.layer.shadowRadius = 10
                        cell.layer.shadowOpacity = 0.35
                        cell.addSubview(teamCircle)
                    }
                    return cell
                    
                case cardCellsRows.favorites:
                    var cell = tableView.dequeueReusableCellWithIdentifier("Favorites") as! MainMenuTableCell
                    cell.clearsContextBeforeDrawing = true
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.setUp()
                    cell.tableView.delegate = self
                    cell.tableView.dataSource = self
                    
                    cell.backView.backgroundColor = Colors.colorWithHexString("F0F0F0")
                    cell.tableView.backgroundColor = Colors.colorWithHexString("F0F0F0")
                    cell.titleLabel.text = "Favorites"
                    cell.titleLabel.backgroundColor = Colors.colorWithHexString("BBA020")
                    var teamCircle:CircleView = CircleView(frame: CGRectMake(self.view.frame.width - 110, 20, 90, 90), text: "STAR", innerColor: UIColor.blackColor().CGColor, rimColor: UIColor.grayColor().CGColor)
                    cell.layer.shadowOffset = CGSizeMake(15, 15);
                    cell.layer.shadowColor = UIColor.blackColor().CGColor;
                    cell.layer.shadowRadius = 10
                    cell.layer.shadowOpacity = 0.35
                    cell.addSubview(teamCircle)
                    circleAdded = true
                    return cell
                case cardCellsRows.rs:
                    var cell = tableView.dequeueReusableCellWithIdentifier("RobotSkills") as! MainMenuTableCell
                    cell.clearsContextBeforeDrawing = true
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.setUp()
                    cell.tableView.delegate = self
                    cell.tableView.dataSource = self
                    
                    cell.backView.backgroundColor = Colors.colorWithHexString("F0F0F0")
                    cell.tableView.backgroundColor = Colors.colorWithHexString("F0F0F0")
                    cell.titleLabel.text = "Robot Skills"
                    cell.titleLabel.backgroundColor = Colors.colorWithHexString("33774C")
                    cell.layer.shadowOffset = CGSizeMake(15, 15);
                    cell.layer.shadowColor = UIColor.blackColor().CGColor;
                    cell.layer.shadowRadius = 10
                    cell.layer.shadowOpacity = 0.35
                    return cell
                case cardCellsRows.ps:
                    var cell = tableView.dequeueReusableCellWithIdentifier("ProgrammingSkills") as! MainMenuTableCell
                    cell.clearsContextBeforeDrawing = true
                    cell.selectionStyle = UITableViewCellSelectionStyle.None
                    cell.setUp()
                    cell.tableView.delegate = self
                    cell.tableView.dataSource = self
                    cell.backView.backgroundColor = Colors.colorWithHexString("F0F0F0")
                    cell.tableView.backgroundColor = Colors.colorWithHexString("F0F0F0")
                    cell.titleLabel.text = "Programming Skills"
                    cell.titleLabel.backgroundColor = Colors.colorWithHexString("8F423E")
                    cell.layer.shadowOffset = CGSizeMake(15, 15);
                    cell.layer.shadowColor = UIColor.blackColor().CGColor;
                    cell.layer.shadowRadius = 10
                    cell.layer.shadowOpacity = 0.35
                    return cell
                default:
                    println("FDSAF")
                    //cell.titleLabel.text = "ERROR"
                }
            }
        }else {
            if tableView == self.searchDisplayController!.searchResultsTableView {
                if !updatingSerach {
                    var cell = (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! MainMenuTableCell).tableView.dequeueReusableCellWithIdentifier("searchResultsCell") as! TeamBookmarkCell
                    cell.teamLabel.text = self.searchResults[indexPath.row].name
                    cell.seasonLabel.text = self.searchResults[indexPath.row].additionalInfo
                    return cell
                }else {
                    if let x = tableView.cellForRowAtIndexPath(indexPath) {
                        return x
                    }else {
                        return UITableViewCell()
                    }
                }
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
                    cell.scoreLabel.text = "\((self.robotSkills.objectAtIndex(indexPath.row) as! Skills).score)"
                    return cell
                case "Programming Skills":
                    var cell = tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
                    cell.rankLabel.text = (self.programmingSkills.objectAtIndex(indexPath.row) as! Skills).rank
                    cell.teamLabel.text = (self.programmingSkills.objectAtIndex(indexPath.row) as! Skills).team
                    cell.scoreLabel.text = "\((self.programmingSkills.objectAtIndex(indexPath.row) as! Skills).score)"
                    return cell
                default:
                    return tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
                }
            }
            return (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! MainMenuTableCell).tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
        }
        return (self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as! MainMenuTableCell).tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
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