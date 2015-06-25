//
//  CompetitionProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/17/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class OverviewCompetitionProfileViewController: HasCompetitionViewController, UITableViewDelegate, UITableViewDataSource {
    var name: String! = ""
    var season: String! = ""
    
    var rankings: NSMutableArray! = NSMutableArray()
    var qualMatchCount: NSInteger = 1000
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet var disclaimer: UILabel!
    @IBOutlet var rankingTable: UITableView!
    @IBOutlet var seasonLabel: UILabel!
    @IBOutlet var locLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    func setAllHidden() {
        self.rankingTable.hidden = true
    }
    
    func dataLoaded() {
        
        self.activityIndicator.stopAnimating()
        if self.comp.date == "League" {
          self.disclaimer.hidden = false
        }else {
            self.rankingTable.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        self.setAllHidden()
        var homeButton: UIBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: "goHome")
        self.tabBarController?.navigationItem.rightBarButtonItem = homeButton
        //self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        //self.activityIndicator.frame = CGRectMake(100, 100, (self.view.frame.width/2) - 50, (self.view.frame.height/2) + 50);
       
       // self.activityIndicator.startAnimating()
        //self.view.addSubview( self.activityIndicator )
        self.rankingTable.dataSource = self
        self.rankingTable.delegate = self
        self.loadComp()
        var x:HasCompetitionViewController = self.tabBarController?.viewControllers![1] as! HasCompetitionViewController!
        x.comp = self.comp as Competition!
        var y:HasCompetitionViewController = self.tabBarController?.viewControllers![2] as! HasCompetitionViewController!
        y.comp = self.comp as Competition!
    }
    
    func loadComp() {
        let ref = Firebase(url: "https://vexscoutcompetitions.firebaseio.com/\(self.season)/\(self.name)")
        ref.observeSingleEventOfType( FEventType.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
            
            self.comp.name = snapshot.value["name"]as! String
            self.comp.date = snapshot.value["date"]as! String
            self.comp.loc = snapshot.value["loc"]as! String
            self.comp.season = snapshot.value["season"] as! String
            self.seasonLabel.text = self.season
            self.locLabel.text = self.comp.loc
            self.dateLabel.text = self.comp.date
            // Matches
            let ref = Firebase(url: "https://vexscoutcompetitions.firebaseio.com/\(self.season)/\(self.name)/matches")
            ref.observeSingleEventOfType( FEventType.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                if snapshot.exists() {
                    let enum2 = snapshot.children
                    // Cycle through each Match
                    while let rest2 = enum2.nextObject() as? FDataSnapshot {
                        var m: Match = Match()
                        m.red1 = rest2.value["r0"] as! String
                        m.red2 = rest2.value["r1"] as! String
                        if let y = rest2.value["r2"]   as? String {
                            m.red3 =  rest2.value["r2"]  as! String
                        }
                        m.blue1 = rest2.value["b0"] as! String
                        m.blue2 = rest2.value["b1"] as! String
                        if let y = rest2.value["b2"]   as? String {
                            
                            m.blue3 =  rest2.value["b2"]  as! String
                        }
                        m.name = rest2.value["num"] as! String
                        let x =  rest2.value["rs"] as! Int!
                        m.redScore = "\(x)"
                        let y = rest2.value["bs"]as! Int!
                        m.blueScore = "\(y)"
                        
                        self.comp.sumOfMatches += m.blueScore.integerValue + m.redScore.integerValue
                        
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
                        
                        self.comp.matchCount++
                        self.comp.matches.addObject(m)
                    }
                    self.calculateRankings()
                    self.comp.orderMatches()
                    self.dataLoaded()
                }
                
                // Awards
                let refAward = Firebase(url: "https://vexscoutcompetitions.firebaseio.com/\(self.season)/\(self.name)/awards")
                refAward.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                    let x = NSNumber(unsignedLong: snapshot.childrenCount) as NSInteger
                    for var i = 1; i <= x; i++ {
                        var a: Award = Award();
                        var team: Team = Team()
                        team.num = snapshot.childSnapshotForPath("\(i)").value["team"] as! String!
                        //println(team.num)
                        a.team = team
                        a.award = snapshot.childSnapshotForPath("\(i)").value["name"] as! String!
                        //println(snapshot.childSnapshotForPath("\(i)").value["award"] as! String!)
                        a.comp = self.comp.name
                        self.comp.awards.addObject(a)
                    }
                })
            })
            //println("RANKINGS!")
        })
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
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = self.colorWithHexString("#f0f0f0")
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
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (count(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
