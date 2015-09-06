//
//  CompetitionProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/17/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class OverviewCompetitionProfileViewController: HasCompetitionViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var eventNameTitleLabel: UILabel!
    var name: String! = ""
    var season: String! = ""
    
    var rankings: NSMutableArray! = NSMutableArray()
    var qualMatchCount: NSInteger = 1000
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var isBookmarked:Bool = false
    
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var disclaimer: UILabel!
    @IBOutlet var rankingTable: UITableView!
    @IBOutlet var seasonLabel: UILabel!
    @IBOutlet var locLabel: UILabel!
    
    func setAllHidden() {
        self.rankingTable.hidden = true
    }
    
    func dataLoaded() {
        self.activityIndicator.stopAnimating()
        self.findIfBookmarked()
        if self.comp.date == "League" {
          self.disclaimer.hidden = false
        }else {
            self.rankingTable.alpha = 0.1
            self.rankingTable.hidden = false
            UIView.animateWithDuration(0.5, animations: {
                self.rankingTable.alpha = 1.0
            })
        }
        var x:HasCompetitionViewController = self.tabBarController?.viewControllers![1] as! HasCompetitionViewController!
        x.comp = self.comp as Competition!
        var y:HasCompetitionViewController = self.tabBarController?.viewControllers![2] as! HasCompetitionViewController!
        y.comp = self.comp as Competition!

    }
    
    override func viewWillAppear(animated: Bool) {
        self.findIfBookmarked()
    }
    
    func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    override func layoutSublayersOfLayer(layer: CALayer!) {
        layer.frame = self.view.bounds
    }

    override func viewDidLoad() {
        
        self.setAllHidden()
       
        self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.activityIndicator.frame = CGRectMake(100, 100, (self.view.frame.width/2), (self.view.frame.height/2) + 50);
       
        self.activityIndicator.startAnimating()
        self.view.addSubview( self.activityIndicator )
        self.rankingTable.dataSource = self
        self.rankingTable.delegate = self
        self.loadComp()
     }
    
    func loadComp() {
        var query = PFQuery(className:"Competitions")
        println(self.comp.compID as String)
        query.getObjectInBackgroundWithId(self.comp.compID as String) {
            (object: PFObject?, error:NSError?) -> Void in
            // reassurance
            if let x = object!["name"] as? String {
                self.comp.name = x
            }else{
                let alertController = UIAlertController(title: "Well, this is awkard!", message:
                    "I can't seem to find this competition! It isn't in our database... Hey it happens" , preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                return
            }
            self.comp.name = object!["name"] as! String
            self.comp.date = object!["date"] as! String
            self.comp.loc = object!["loc"] as! String
            self.comp.season = object!["season"] as! String
            self.comp.compID = object!.objectId
            self.seasonLabel.text = self.season
            self.dateLabel.text = self.comp.date
            self.locLabel.text = self.comp.loc
             self.eventNameTitleLabel.text = self.comp.name
           // self.eventNameTitleLabel.
            //self.comp.date
            
            var query = PFQuery(className:"Matches")
            query.whereKey("compID", equalTo: self.comp.compID)
            query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]?, error: NSError?) -> Void in
                // Parse into Match objects
                for mRaw in objects! {
                    var m = Match()
                    m.name = (mRaw as! PFObject)["num"] as! String
                    m.blue1 = (mRaw as! PFObject)["b0"] as! String
                    m.blue2 = (mRaw as! PFObject)["b1"] as! String
                    if let x = (mRaw as! PFObject)["b2"] as? String {
                        m.blue3 = x
                    }
                    m.red1 = (mRaw as! PFObject)["r0"] as! String
                    m.red2 = (mRaw as! PFObject)["r1"] as! String
                    if let x = (mRaw as! PFObject)["r2"] as? String {
                        m.red3 = x
                    }
                    var x = ((mRaw as! PFObject)["bs"] as! Int)
                    m.blueScore = "\(x)"
                    var y = ((mRaw as! PFObject)["rs"] as! Int)
                    m.redScore = "\(y)"
                    self.comp.sumOfMatches += m.blueScore.integerValue + m.redScore.integerValue
                    println(m.blue2)
                    // Quals Counter
                    if m.isQualsMatch() {
                        self.comp.qualsCount++
                    }else {
                        self.comp.elimCount++
                    }
                    
                    // Check Highscore and Lowscores for team and comp
                    
                    if m.redScore.integerValue > self.comp.highestScore {
                        self.comp.highestScore = m.redScore.integerValue
                    }else if m.redScore.integerValue < self.comp.lowestScore {
                        self.comp.lowestScore = m.redScore.integerValue
                    }
                    
                    // Add Matches to each teams (for rankings calculations)
                    self.comp.addMatchToTeam(m.red1, m: m)
                    self.comp.addMatchToTeam(m.red2, m: m)
                    self.comp.addMatchToTeam(m.blue1, m: m)
                    self.comp.addMatchToTeam(m.blue2, m: m)
                    
                    
                    m.name = m.name.stringByReplacingOccurrencesOfString(" ", withString: "")
                    if m.name.uppercaseString.rangeOfString("QF") != nil {
                        m.name = m.name.stringByReplacingOccurrencesOfString("Q", withString: "")
                        m.name = m.name.stringByReplacingOccurrencesOfString("F", withString: "")
                        self.comp.qf.addObject(m)
                    }else if m.name.uppercaseString.rangeOfString("SF") != nil {
                        m.name = m.name.stringByReplacingOccurrencesOfString("S", withString: "")
                        m.name = m.name.stringByReplacingOccurrencesOfString("F", withString: "")
                        self.comp.sf.addObject(m)
                    }else if m.name.uppercaseString.rangeOfString("F") != nil {
                        m.name = m.name.stringByReplacingOccurrencesOfString("F", withString: "")
                        self.comp.finals.addObject(m)
                    }else {
                        m.name = m.name.stringByReplacingOccurrencesOfString("Q", withString: "")
                        self.comp.quals.addObject(m)
                    }
                    self.comp.matchCount++
                    self.comp.matches.addObject(m)
                }
                self.calculateRankings()
                self.comp.orderMatches()
                self.dataLoaded()
            })
            var awardQuery = PFQuery(className: "Awards")
            awardQuery.whereKey("compID", equalTo: self.comp.compID)
            awardQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error: NSError?) -> Void in
                for result in (objects as! [PFObject]) {
                    var a: Award = Award();
                    var team: Team = Team()
                    team.num = result["team"] as! String!
                    a.team = team
                    a.award = result["name"] as! String!
                    a.comp = self.comp.name
                    self.comp.awards.addObject(a)
                }
            })
        }
    }
    
    func calculateRankings() {
        var tempArray: NSMutableArray! = self.comp.teams
        for (var i = 0; i < tempArray.count; i++) {
            var t: Team! = tempArray.objectAtIndex(i) as! Team
            t.calculateQualCount()
            println("fadsf \(t.qualCount) and \(self.qualMatchCount)")
            if self.qualMatchCount > t.qualCount {
                self.qualMatchCount = t.qualCount
            }
        }
        
        // Sorting 3.0
        for (var i = 0; i < tempArray.count; i++) {
            var t: Team! = tempArray.objectAtIndex(i) as! Team
            t.calculateStats(self.qualMatchCount)
            for (var y = i; y > -1; y--) {
                if (t.wp > (tempArray.objectAtIndex(y) as! Team).wp ) {
                    tempArray.removeObjectAtIndex(y + 1)
                    tempArray.insertObject(t, atIndex: y)
                    
                }else if (t.wp == (tempArray.objectAtIndex(y) as! Team).wp) {
                    if t.spPointsSum > (tempArray.objectAtIndex(y) as! Team).spPointsSum {
                        tempArray.removeObjectAtIndex(y + 1)
                        tempArray.insertObject(t, atIndex: y)
                    }
                }
            }
        }
        /*// Sorting 2.0
        for (var i = 0; i < tempArray.count; i++) {
        var t: Team! = tempArray.objectAtIndex(i) as! Team
        t.calculateStats()
        for (var y = i; y > -1; y--) {
        if (t.winMatchQualsCount > (tempArray.objectAtIndex(y) as! Team).winMatchQualsCount ) {
        tempArray.removeObjectAtIndex(y + 1)
        tempArray.insertObject(t, atIndex: y)
        }else if (t.winMatchQualsCount == (tempArray.objectAtIndex(y) as! Team).winMatchQualsCount ) {
        if (t.tieMatchQualsCount > (tempArray.objectAtIndex(y) as! Team).tieMatchQualsCount) {
        tempArray.removeObjectAtIndex(y + 1)
        tempArray.insertObject(t, atIndex: y)
        }else if (t.tieMatchQualsCount == (tempArray.objectAtIndex(y) as! Team).tieMatchQualsCount) {
        if t.spPointsSum > (tempArray.objectAtIndex(y) as! Team).spPointsSum {
        tempArray.removeObjectAtIndex(y + 1)
        tempArray.insertObject(t, atIndex: y)
        }
        }
        }
        }
        }*/
        
        /*
        //Old Sorting
        // Sort by Wins
        for (var i = 0; i < tempArray.count; i++) {
        var t: Team! = tempArray.objectAtIndex(i) as! Team
        t.calculateStats()
        for (var y = i; y > -1; y--) {
        if (t.winMatchQualsCount > (tempArray.objectAtIndex(y) as! Team).winMatchQualsCount ) {
        tempArray.removeObjectAtIndex(y + 1)
        tempArray.insertObject(t, atIndex: y)
        }
        }
        }
        // Sort by Ties if same num of wins
        for (var i = 0; i < tempArray.count; i++) {
        var t: Team! = tempArray.objectAtIndex(i) as! Team
        for (var y = i; y > -1; y--) {
        if (t.tieMatchQualsCount > (tempArray.objectAtIndex(y) as! Team).tieMatchQualsCount && t.winMatchQualsCount == (tempArray.objectAtIndex(y) as! Team).winMatchQualsCount) {
        tempArray.removeObjectAtIndex(y + 1)
        tempArray.insertObject(t, atIndex: y)
        }
        }
        }
        // Sort by SP Points finally!
        for (var i = 0; i < tempArray.count; i++) {
        var t: Team! = tempArray.objectAtIndex(i) as! Team
        for (var y = i; y > -1; y--) {
        if (t.tieMatchQualsCount == (tempArray.objectAtIndex(y) as! Team).tieMatchQualsCount && t.winMatchQualsCount == (tempArray.objectAtIndex(y) as! Team).winMatchQualsCount) && t.spPointsSum > (tempArray.objectAtIndex(y) as! Team).spPointsSum{
        tempArray.removeObjectAtIndex(y + 1)
        tempArray.insertObject(t, atIndex: y)
        }
        }
        }*/
        /*for (var i = 0; i < tempArray.count; i++) {
            var t: Team! = tempArray.objectAtIndex(i) as! Team
            self.rankingTable.reloadData()
        }*/
        self.rankings = tempArray
        
        self.rankingTable.reloadData()
    }
    
    func findIfBookmarked() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let curBookmarks = defaults.valueForKey("Bookmarks Comp") as? NSArray {
            var book: NSMutableArray = NSMutableArray(array: curBookmarks)
            for (var i = 0; i < book.count; i++) {
                var curEl: NSDictionary = book.objectAtIndex(i) as! NSDictionary
               // println(curEl)
                //println(self.getCurrentDictionaryBookmark())
                // if num and season equal current ones
                if (curEl.objectForKey("Name") as! NSString).isEqualToString(self.name) && (curEl.objectForKey("Season") as! NSString).isEqualToString(self.season){
                    isBookmarked = true
                    self.favoriteButton.setImage(UIImage(named: "FavoritedIcon.png"), forState: .Normal)
                   // println("IT WORKED")
                    return
                }
            }
        }
        isBookmarked = false
    }

    @IBAction func favorite(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if !isBookmarked {
            // Get the bookmarks array
            if let curBookmarks = defaults.valueForKey("Bookmarks Comp") as? NSArray {
                var book: NSMutableArray = NSMutableArray(array: curBookmarks)
                // Add new team to bookmarks
                book.addObject(self.getCurrentDictionaryBookmark())
                defaults.setObject(book as NSArray, forKey: "Bookmarks Comp")
                defaults.synchronize()
            }else { // This is the first bookmark
                var bookmarks: NSArray = [(self.getCurrentDictionaryBookmark())]
                defaults.setObject(bookmarks, forKey: "Bookmarks Comp")
                defaults.synchronize()
            }
            self.isBookmarked = true
            self.favoriteButton.setImage(UIImage(named: "FavoritedIcon.png"), forState: .Normal)
        }else { // Remove the current profile from bookmarks
            let curBookmarks = defaults.valueForKey("Bookmarks Comp") as? NSArray
            var book: NSMutableArray = NSMutableArray(array: curBookmarks!)
            // loop through and find item with num and season equal to current profile, find index
            var index = 0
            for (var i = 0; i < book.count; i++) {
                var curEl: NSDictionary = book.objectAtIndex(i) as! NSDictionary
                // if num and season equal current ones
                if (curEl.objectForKey("Name") as! NSString).isEqualToString(self.comp.name) && (curEl.objectForKey("Season") as! NSString).isEqualToString(self.comp.season){
                    index = i
                }
            }
            book.removeObjectAtIndex(index)
            // Update bookmarks
            defaults.setObject(book as NSArray, forKey: "Bookmarks Comp")
            defaults.synchronize()
            self.isBookmarked = false
            self.favoriteButton.setImage(UIImage(named: "UnfavoritedIcon.png"), forState: .Normal)
        }
        //println(defaults.valueForKey("Bookmarks Comp") as? NSArray)
    }
    
    func getCurrentDictionaryBookmark() -> NSDictionary {
        var curEl: NSMutableDictionary = NSMutableDictionary()
        curEl.setObject("Comp", forKey: "Kind")
        curEl.setObject(self.name, forKey: "Name")
        curEl.setObject(self.season, forKey: "Season")
        curEl.setObject(self.comp.compID, forKey: "ID")
        return curEl as NSDictionary
    }

    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Ranking"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! UITabBarController
        // Set the title of the teamcontroller
        vc.title = "Team \((self.rankings.objectAtIndex(indexPath.row) as! Team).num)"
        // Destintation ViewController, set team
        let dest: OverviewTeamProfileViewController = vc.viewControllers?.first as! OverviewTeamProfileViewController
        
        var t: Team! = self.rankings.objectAtIndex(indexPath.row) as! Team
        t.season = self.comp.season
        dest.team = t
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("RankingCell") as! RankingTableCell
        
        
        var t: Team! = self.rankings.objectAtIndex(indexPath.row) as! Team
        cell.rank.text = "\(indexPath.row + 1)."
        cell.teamLabel.text = t.num
        var win = "\(t.winMatchQualsCount) - "
        var loss = "\(t.lostMatchQualsCount) - "
        var tie = "\(t.tieMatchQualsCount)"
        cell.rankingLabel.text = "\(win)\(loss)\(tie)"
        cell.spLabel.text = "\(t.spPointsSum)"
        if indexPath.row % 2 == 0 {
            //println("ROW: \(indexPath.row)")
            cell.backgroundColor = Colors.colorWithHexString("#f0f0f0")
        }else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rankings.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}