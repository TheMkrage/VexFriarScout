//
//  OverviewTeamProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/10/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class OverviewTeamProfileViewController: HasTeamViewController {

    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numLabel: UILabel!
    @IBOutlet var compCountLabel: UILabel!
    @IBOutlet var awardCountLabel: UILabel!
    @IBOutlet var highestScoreLabel: UILabel!
    
    @IBOutlet var spAvgLabel: UILabel!
    @IBOutlet var averageLabel: UILabel!
    @IBOutlet var lowScoreLabel: UILabel!
    override func viewDidLoad() {
        self.loadCompetitions()
        var x:HasTeamViewController = self.tabBarController?.viewControllers![1] as! HasTeamViewController!
        x.team = self.team as Team!
        var y:HasTeamViewController = self.tabBarController?.viewControllers![2] as! HasTeamViewController!
        y.team = self.team as Team!
        
        }
    
    func loadCompetitions() {
        println("Will Appear")
        self.team.competitions = NSMutableArray()
        
        // General Info
        let ref1 = Firebase(url: "https://vexscout.firebaseio.com/teams/\(team.num)")
        ref1.observeSingleEventOfType(.Value, withBlock: { (snapshot:FDataSnapshot!) -> Void in
            self.team.name = snapshot.value["name"] as! String
            self.team.loc = snapshot.value["loc"] as! String
            self.team.num = snapshot.value["num"] as! String
            self.nameLabel.text = self.team.name
            self.locationLabel.text = self.team.loc
            self.numLabel.text = self.team.num

        })
        // Competitions
        let refComp = Firebase(url: "https://vexscout.firebaseio.com/teams/\(team.num)/comps")
        refComp.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot:FDataSnapshot!) -> Void in
            println("Begin!")
            
            // Cycle through each competition
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                var comp: Competition = Competition()
                comp.name = rest.value["name"]as! String
                comp.date = rest.value["date"]as! String
                comp.loc = rest.value["loc"]as! String
                comp.season = rest.value["season"] as! String
                // Matches
                let ref = Firebase(url: "https://vexscout.firebaseio.com/teams/\(self.team.num)/comps/Skyrise/\(comp.name)/matches")
                ref.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
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
                            
                            // Win Loss Counters
                            if m.didTeamTie(self.team.num) {
                                self.team.tieMatchCount++
                                self.team.tieMatchScoreSum += m.scoreForTeam(self.team.num)
                            }else if m.didTeamWin(self.team.num) {
                                self.team.winMatchCount++
                                self.team.winMatchScoreSum += m.scoreForTeam(self.team.num)
                            }else {
                                self.team.lostMatchCount++
                                self.team.lostMatchScoreSum += 
                                m.scoreForTeam(self.team.num)
                            }
                            // Now For Quals Matches
                            if m.isQualsMatch() {
                                // Win Loss Counters
                                if m.didTeamTie(self.team.num) {
                                    self.team.tieMatchQualsCount++
                                    self.team.tieMatchQualsSum += m.scoreForTeam(self.team.num)
                                }else if m.didTeamWin(self.team.num) {
                                    self.team.winMatchQualsCount++
                                    self.team.winMatchQualsSum += m.scoreForTeam(self.team.num)
                                }else {
                                    self.team.lostMatchQualsCount++
                                    self.team.lostMatchQualsSum +=
                                        m.scoreForTeam(self.team.num)
                                }
                            }
                            // Find Team Color and Act Accordingly
                            let teamColor:NSString! = m.colorTeamIsOn(self.team.num)
                            if teamColor.isEqualToString("red") {
                                let score:Int =  rest2.value["rscore"] as! Int
                                self.team.sumOfMatches += score
                                comp.sumOfMatches += score
                               
                                // Find SP Points
                                if m.isQualsMatch() {
                                    comp.qualsCount++
                                    // if Team Won
                                    if m.didTeamWin(self.team.num) {
                                        // If the other alliance was a no-show, add red's score, else add the opponents score
                                        if m.blueScore.toInt() == 0 {
                                            self.team.spPointsSum += m.redScore.toInt()!
                                            comp.spPointsSum += m.redScore.toInt()!
                                        }else {
                                            self.team.spPointsSum += m.blueScore.toInt()!
                                            comp.spPointsSum += m.blueScore.toInt()!
                                        }
                                    }else {
                                        self.team.spPointsSum += m.redScore.toInt()!
                                        comp.spPointsSum += m.redScore.toInt()!
                                    }
                                    println(comp.spPointsSum)
                                }else {
                                    comp.elimCount++
                                }
                                // Check Highscore and Lowscores for team and comp
                                if m.redScore.toInt() > self.team.highestScore {
                                    self.team.highestScore = m.redScore.toInt()!
                                }else if m.redScore.toInt() < self.team.lowestScore {
                                    self.team.lowestScore = m.redScore.toInt()!
                                }
                                if m.redScore.toInt() > comp.highestScore {
                                    comp.highestScore = m.redScore.toInt()!
                                }else if m.redScore.toInt() < comp.lowestScore {
                                    comp.lowestScore = m.redScore.toInt()!
                                }
                            }else if teamColor.isEqualToString("blue") {
                                let score:Int = rest2.value["bscore"] as! Int
                                self.team.sumOfMatches += score
                                comp.sumOfMatches += score
                                // Find SP Points
                                if m.isQualsMatch() {
                                    comp.qualsCount++
                                    // if Team Won
                                    if m.didTeamWin(self.team.num) {
                                        // If the other alliance was a no-show, add red's score, else add the opponents score
                                        if m.redScore.toInt() == 0 {
                                            self.team.spPointsSum += m.blueScore.toInt()!
                                            comp.spPointsSum += m.blueScore.toInt()!
                                        }else {
                                            self.team.spPointsSum += m.redScore.toInt()!
                                            comp.spPointsSum += m.redScore.toInt()!
                                        }
                                        
                                    }else {
                                        self.team.spPointsSum += m.blueScore.toInt()!
                                        comp.spPointsSum += m.blueScore.toInt()!
                                    }
                                    println(comp.spPointsSum)
                                }else {
                                    comp.elimCount++
                                }
                                
                                // Check Highscore and Lowscores for team and comp
                                if m.blueScore.toInt() > self.team.highestScore {
                                    self.team.highestScore = m.blueScore.toInt()!
                                }
                                if m.blueScore.toInt() < self.team.lowestScore {
                                    self.team.lowestScore = m.blueScore.toInt()!
                                }
                                if m.blueScore.toInt() > comp.highestScore {
                                    comp.highestScore = m.blueScore.toInt()!
                                }
                                if m.blueScore.toInt() < comp.lowestScore {
                                    comp.lowestScore = m.blueScore.toInt()!
                                }
                            }else {
                                println("ERROR")
                            }
                            comp.matchCount++
                            println(comp.name)
                            
                            self.team.matchCount++
                            comp.matches.addObject(m)
                        }
                    }
                    // Awards
                    let refAward = Firebase(url: "https://vexscout.firebaseio.com/teams/\(self.team.num)/comps/Skyrise/\(comp.name)/awards")
                    refAward.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                        let x = NSNumber(unsignedLong: snapshot.childrenCount) as NSInteger
                        for var i = 0; i < x; i++ {
                            var a: Award = Award();
                        
                            a.award = snapshot.value[i] as! String!
                            a.comp = comp.name
                            a.team = self.team
                            
                            self.team.awards.addObject(a)
                            self.team.awardCount++
                            println("INT HERE \(self.team.awardCount)")
                            
                            self.awardCountLabel.text = "\(self.team.awardCount)"
                        }
                    })
                    self.team.compCount++
                    self.compCountLabel.text = "\(self.team.compCount)"
                    
                    println("HERE YOU GO: \(self.team.awardCount)")
                    comp.orderMatches()
                    self.team.competitions.addObject(comp)
                    self.updateLabels()
                                       
                })
            }
            self.updateLabels()
        })
        
    }
    
   
    func updateLabels() {
        var sumOfspAvgs: NSInteger = 0
        for c in self.team.competitions {
            sumOfspAvgs += (c as! Competition).getSPAverage()
        }

        if self.team.compCount != 0 {
            self.spAvgLabel.text = "\(sumOfspAvgs/self.team.compCount)"
        }
        self.highestScoreLabel.text = "\(self.team.highestScore)"
        self.lowScoreLabel.text = "\(self.team.lowestScore)"
        if  self.team.matchCount != 0 {
            let x = "\(self.team.sumOfMatches/self.team.matchCount)"
            self.averageLabel.text = x;
        }
    }
    
}
