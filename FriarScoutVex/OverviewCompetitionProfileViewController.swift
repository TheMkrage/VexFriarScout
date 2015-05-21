//
//  CompetitionProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/17/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class OverviewCompetitionProfileViewController: HasCompetitionViewController {
    var name: String! = ""
    var season: String! = ""
    
    var rankings: NSMutableArray! = NSMutableArray()
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    override func viewDidLoad() {
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
                        println(self.comp.name)
                        
                        println("ADDING MATCHES")
                        self.comp.matches.addObject(m)
                    }
                    self.calculateRankings()
                }
                self.comp.orderMatches()
                // Awards
                let refAward = Firebase(url: "https://vexscoutcompetitions.firebaseio.com/\(self.season)/\(self.name)/awards")
                refAward.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                    let x = NSNumber(unsignedLong: snapshot.childrenCount) as NSInteger
                    for var i = 1; i <= x; i++ {
                        var a: Award = Award();
                        var team: Team = Team()
                        team.num = snapshot.childSnapshotForPath("\(i)").value["team"] as! String!
                        a.team = team
                        a.award = snapshot.childSnapshotForPath("\(i)").value["award"] as! String!
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
            for (var y = i; y > -1; y--) {
                if (t.calculateWins() < (tempArray.objectAtIndex(y) as! Team).calculateWins() ) {
                    tempArray.removeObjectAtIndex(y + 1)
                    tempArray.insertObject(t, atIndex: y)
                }
            }
        }
        for (var i = 0; i < tempArray.count; i++) {
            var t: Team! = tempArray.objectAtIndex(i) as! Team
            println(t.num)
        }
        

    }

}
