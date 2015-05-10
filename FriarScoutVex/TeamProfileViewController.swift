//
//  TeamProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/9/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class TeamProfileViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var competitionsTable: UITableView!
    @IBOutlet var highestScoreLabel: UILabel!
    var competitions: NSMutableArray!
    var highestScore: NSInteger = 0
    var matchCount: NSInteger = 0
    var sumOfMatches: NSInteger = 0
    @IBOutlet var averageLabel: UILabel!
    @IBOutlet var lowScoreLabel: UILabel!
    var team: Team! = Team()
    override func viewWillAppear(animated: Bool) {
            }
    override func viewDidLoad() {
        self.loadCompetitions()
        
        //set delegates and datasources
        self.competitionsTable.delegate = self
        self.competitionsTable.dataSource = self
        
    }
    
    func loadCompetitions() {
        println("Will Appear")
        self.competitions = NSMutableArray()
        let ref = Firebase(url: "https://vexscout.firebaseio.com/teams/\(team.num)/comps")
        ref.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot:FDataSnapshot!) -> Void in
            println("Begin!")
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                var comp: Competition = Competition()
                comp.name = rest.value["name"]as! String
                comp.date = rest.value["date"]as! String
                comp.loc = rest.value["loc"]as! String
                comp.season = rest.value["season"] as! String
                
                let ref = Firebase(url: "https://vexscout.firebaseio.com/teams/\(self.team.num)/comps/Skyrise/\(comp.name)/matches")
                ref.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                    if snapshot.exists() {
                        let enum2 = snapshot.children
                        
                        while let rest2 = enum2.nextObject() as? FDataSnapshot {
                            var m: Match = Match()
                            println(rest2.value)
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
                            
                            if m.colorTeamIsOn(self.team.num).isEqualToString("red") {
                                self.sumOfMatches += rest2.value["rscore"] as! Int
                                if m.redScore.toInt() > self.highestScore {
                                    self.highestScore = m.redScore.toInt()!
                                }
                            }else if m.colorTeamIsOn(self.team.num).isEqualToString("blue") {
                                self.sumOfMatches += rest2.value["bscore"] as! Int
                                if m.blueScore.toInt() > self.highestScore {
                                    self.highestScore = m.blueScore.toInt()!
                                }
                            }
                            self.matchCount++
                            comp.matches.addObject(m)
                        }
                    }
                    self.competitions.addObject(comp)
                    self.highestScoreLabel.text = "\(self.highestScore)"
                    self.averageLabel.text = "\(self.sumOfMatches/self.matchCount)"
                    self.competitionsTable.reloadData()
                    
                    
                })
            }
        })

    }
    
    //TABLE STUFF
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // In case competitions
        if !(self.competitions != nil) {
            return 0
        }
        return competitions.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Competitions"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Sorts numerically
        //sorted = self.sortArray(teams)
        
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("CompetitionCell") as! CompetitionTableCell
        cell.nameLabel.text = (self.competitions.objectAtIndex(indexPath.row) as! Competition).name as String
         cell.dateLabel.text = (self.competitions.objectAtIndex(indexPath.row) as! Competition).date as String
         cell.LocationLabel.text = (self.competitions.objectAtIndex(indexPath.row) as! Competition).loc as String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompetitionProfile") as! CompetitionForTeamProfile
        // Set the title of the menuViewController
        vc.title = "\(competitions.objectAtIndex(indexPath.row).name as String)"
        // Destintation ViewController, set team
        var comp:Competition! = Competition()
        comp = competitions.objectAtIndex(indexPath.row) as! Competition
        var t: Team! = Team()
        team.num = self.title
        vc.team = team
        vc.comp = comp
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
    }

}
