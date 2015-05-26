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
    
    @IBOutlet var rankingTable: UITableView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    override func viewDidLoad() {
        
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
            self.nameLabel.text = self.comp.name
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
                        m.red1 = rest2.value["rteam 0"] as! String
                        m.red2 = rest2.value["rteam 1"] as! String
                        if let y = rest2.value["rteam 2"]   as? String {
                            m.red3 =  rest2.value["rteam 2"]  as! String
                        }
                        m.blue1 = rest2.value["bteam 0"] as! String
                        m.blue2 = rest2.value["bteam 1"] as! String
                        if let y = rest2.value["bteam 2"]   as? String {
                            
                            m.blue3 =  rest2.value["bteam 2"]  as! String
                        }
                        m.name = rest2.value["num"] as! String
                        let x =  rest2.value["rscore"] as! Int!
                        m.redScore = "\(x)"
                        let y = rest2.value["bscore"]as! Int!
                        m.blueScore = "\(y)"
                        
                        self.comp.sumOfMatches += m.blueScore.toInt()! + m.redScore.toInt()!
                        
                        // Quals Counter
                        if m.isQualsMatch() {
                            self.comp.qualsCount++
                        }else {
                            self.comp.elimCount++
                        }
                        
                        // Check Highscore and Lowscores for team and comp
                        
                        if m.redScore.toInt() > self.comp.highestScore {
                            self.comp.highestScore = m.redScore.toInt()!
                        }else if m.redScore.toInt() < self.comp.lowestScore {
                            self.comp.lowestScore = m.redScore.toInt()!
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
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("RankingCell") as! RankingTableCell
        
        
        var t: Team! = self.rankings.objectAtIndex(indexPath.row) as! Team
        cell.rank.text = "\(indexPath.row + 1)"
        cell.teamLabel.text = t.num
        cell.winsLabel.text = "\(t.winMatchQualsCount)-"
        cell.lossLabel.text = "\(t.lostMatchQualsCount)-"
        cell.tieLabel.text = "\(t.tieMatchQualsCount)"
        cell.spLabel.text = "\(t.spPointsSum)"
        
        
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rankings.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
