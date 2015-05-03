//
//  CompetitionForTeamProfile.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/21/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class CompetitionForTeamProfile: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var competition: Competition!
    var team: Team!
    var matches: NSMutableArray!
    @IBOutlet var matchesTable: UITableView!
    
    override func viewDidLoad() {
        self.matchesTable.dataSource = self
        self.matchesTable.delegate = self
        matches = NSMutableArray()
        let ref = Firebase(url: "https://vexscout.firebaseio.com/teams/\(team.num)/comps/\(competition.name)/matches")
        ref.queryOrderedByValue().observeEventType(.ChildAdded, withBlock: { (snapshot :FDataSnapshot!) -> Void in
            println("here:\(snapshot)")
            var m: Match = Match()
            m.red1 = snapshot.value["rteam 0"] as! String
            m.red2 = snapshot.value["rteam 1"] as! String
            if let y = snapshot.value["rteam 2"]   as? String {
                m.red3 =  snapshot.value["rteam 2"]  as! String
            }
            m.blue1 = snapshot.value["bteam 0"] as! String
            m.blue2 = snapshot.value["bteam 1"] as! String
            if let y = snapshot.value["bteam 2"]   as? String {
                
                m.blue3 =  snapshot.value["bteam 2"]  as! String
            }
            m.name = snapshot.value["num"] as! String
            let x =  snapshot.value["rscore"] as! Int!
            m.redScore = "\(x)"
            let y = snapshot.value["bscore"]as! Int!
            m.blueScore = "\(y)"
            self.matches.addObject(m)
            self.matchesTable.reloadData()
        })
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "matches"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("MatchCell") as! MatchTableCell
        
        var m: Match = self.matches.objectAtIndex(indexPath.row) as! Match
        cell.matchNameLabel.text = m.name
        cell.redTeam1Label.text = m.red1
        cell.redTeam2Label.text = m.red2
        cell.redTeam3Label.text = m.red3
        cell.blueTeam1Label.text = m.blue1
        cell.blueTeam2Label.text = m.blue2
        cell.blueTeam3Label.text = m.blue3
        cell.redScoreLabel.text = m.redScore
        cell.blueScoreLabel.text = m.blueScore
        
        
        return cell

        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.matches.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
