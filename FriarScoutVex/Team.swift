//
//  Team.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/3/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class Team: NSObject {
    
    var name:String! = ""
    var num: String! = ""
    var loc: String! = ""
    var org: String! = ""
    var season: String! = ""
    
    var numOnly:String! {
        get{
            var teamDigits:String = ""
            var teamLetters:String = ""
            let letters = NSCharacterSet.letterCharacterSet()
            let digits = NSCharacterSet.decimalDigitCharacterSet()
            let characters = Array(self.num)
            for c in self.num.unicodeScalars {
                if letters.longCharacterIsMember(c.value) {
                    teamLetters.append(c)
                } else if digits.longCharacterIsMember(c.value) {
                    teamDigits.append(c)
                }
            }
            return teamDigits
        }
    }
    var letterOnly: String! {
        
        get{
            var teamDigits:String = ""
            var teamLetters:String = ""
            let letters = NSCharacterSet.letterCharacterSet()
            let digits = NSCharacterSet.decimalDigitCharacterSet()
            let characters = Array(self.num)
            for c in self.num.unicodeScalars {
                if letters.longCharacterIsMember(c.value) {
                    teamLetters.append(c)
                } else if digits.longCharacterIsMember(c.value) {
                    teamDigits.append(c)
                }
            }
            return teamLetters
        }
        
    }
    
    var rs: String! = "NA"
    var ps: String! = "NA"
    
    var competitionIDs: NSMutableArray! = NSMutableArray()
    var competitions: NSMutableArray! = NSMutableArray()
    var awards: NSMutableArray! = NSMutableArray()
    
    // Specific for TEam Profiles
    var highestScore: NSInteger = 0
    var lostMatchCount: NSInteger = 0
    var lostMatchScoreSum: NSInteger = 0
    var winMatchScoreSum: NSInteger = 0
    var tieMatchScoreSum: NSInteger = 0
    var tieMatchCount: NSInteger = 0
    
    var lostMatchQualsCount: NSInteger = 0
    var lostMatchQualsSum: NSInteger = 0
    var winMatchQualsCount: NSInteger = 0
    var winMatchQualsSum: NSInteger = 0
    var tieMatchQualsSum: NSInteger = 0
    var tieMatchQualsCount: NSInteger = 0
    
    
    var winMatchCount: NSInteger = 0
    var matchCount: NSInteger = 0
    var sumOfMatches: NSInteger = 0
    var lowestScore: NSInteger = NSInteger.max
    var spPointsSum: NSInteger = 0
    var compCount: NSInteger = 0
    var awardCount: NSInteger = 0
    var qualCount: NSInteger = 0
    
    
    
    // For use with comp overview
    var matches:NSMutableArray! = NSMutableArray()
    var statArray: NSMutableArray = NSMutableArray()
    
    var wp: NSInteger = 0 
    
    static func loadTeam(var team:Team) -> Team? {
        var query = PFQuery(className:"Teams")
        query.whereKey("num", equalTo:team.num)
        var objects = query.findObjects()
        println(team.num)
        if (objects == nil || objects!.isEmpty) {
            return nil
        }
        if let newTeam: AnyObject = objects?[0] {
            // Find and set simple values
            team.name = newTeam["name"] as! String
            team.loc =  newTeam["loc"] as! String
            team.num = newTeam["num"] as! String
            team.competitionIDs = newTeam["competitions"] as! NSMutableArray
            var query = PFQuery(className:"Competitions")
            query.whereKey("season", equalTo: team.season)
            query.whereKey("teams", equalTo: team.num)
            var results = query.findObjects() as? [PFObject]
                if true {
                    for result in results! {
                        var comp: Competition = Competition()
                        comp.compID = result.objectId
                        var compID = comp.compID
                        comp.name = result["name"] as! String
                        
                        //println(comp.name)
                        //println(result!["season"] as! String)
                        comp.date = result["date"] as! String
                        comp.loc = result["loc"] as! String
                        comp.season = result["season"] as! String
                        // get matches for each comp
                        var matchIDQuery = PFQuery(className: "Matches")
                        matchIDQuery.whereKey("compID", equalTo: compID)
                        var matchesB0 = PFQuery(className: "Matches")
                        matchesB0.whereKey("b0", equalTo: team.num)
                        var matchesB1 = PFQuery(className: "Matches")
                        matchesB1.whereKey("b1", equalTo: team.num)
                        var matchesB2 = PFQuery(className: "Matches")
                        matchesB2.whereKey("b2", equalTo: team.num)
                        var matchesR0 = PFQuery(className: "Matches")
                        matchesR0.whereKey("r0", equalTo: team.num)
                        var matchesR1 = PFQuery(className: "Matches")
                        matchesR1.whereKey("r1", equalTo: team.num)
                        var matchesR2 = PFQuery(className: "Matches")
                        matchesR2.whereKey("r2", equalTo: team.num)
                        var matchesRaw = NSMutableArray()
                        matchesRaw.addObjectsFromArray( PFQuery.orQueryWithSubqueries([ matchesB0, matchesB1, matchesB2, matchesR0, matchesR1, matchesR2]).whereKey("compID", equalTo: compID).findObjects() as NSArray! as! [PFObject])
                        // Parse into Match objects
                        for mRaw in matchesRaw {
                            var m:Match = Match()
                            m.red1 = mRaw["r0"] as! String
                            m.red2 = mRaw["r1"] as! String
                            if let y = mRaw["r2"]   as? String {
                                m.red3 =  mRaw["r2"]  as! String
                            }
                            m.blue1 = mRaw["b0"] as! String
                            m.blue2 = mRaw["b1"] as! String
                            if let y = mRaw["b2"]   as? String {
                                
                                m.blue3 =  mRaw["b2"]  as! String
                            }
                            m.name = mRaw["num"] as! String
                            m.name = m.name.stringByReplacingOccurrencesOfString(" ", withString: "")
                            if m.name.uppercaseString.rangeOfString("QF") != nil {
                                m.name = m.name.stringByReplacingOccurrencesOfString("Q", withString: "")
                                m.name = m.name.stringByReplacingOccurrencesOfString("F", withString: "")
                                comp.qf.addObject(m)
                            }else if m.name.uppercaseString.rangeOfString("SF") != nil {
                                m.name = m.name.stringByReplacingOccurrencesOfString("S", withString: "")
                                m.name = m.name.stringByReplacingOccurrencesOfString("F", withString: "")
                                comp.sf.addObject(m)
                            }else if m.name.uppercaseString.rangeOfString("F") != nil {
                                m.name = m.name.stringByReplacingOccurrencesOfString("F", withString: "")
                                comp.finals.addObject(m)
                            }else {
                                m.name = m.name.stringByReplacingOccurrencesOfString("Q", withString: "")
                                comp.quals.addObject(m)
                            }
                            
                            let x =  mRaw["rs"] as! Int!
                            m.redScore = "\(x)"
                            let y = mRaw["bs"]as! Int!
                            m.blueScore = "\(y)"
                            // Win Loss Counters
                            if m.didTeamTie(team.num) {
                                team.tieMatchCount++
                                team.tieMatchScoreSum += m.scoreForTeam(team.num)
                            }else if m.didTeamWin(team.num) {
                                team.winMatchCount++
                                team.winMatchScoreSum += m.scoreForTeam(team.num)
                            }else {
                                team.lostMatchCount++
                                team.lostMatchScoreSum +=
                                    m.scoreForTeam(team.num)
                            }
                            // Now For Quals Matches
                            if m.isQualsMatch() {
                                team.qualCount++
                                // Win Loss Counters
                                if m.didTeamTie(team.num) {
                                    team.tieMatchQualsCount++
                                    team.tieMatchQualsSum += m.scoreForTeam(team.num)
                                }else if m.didTeamWin(team.num) {
                                    team.winMatchQualsCount++
                                    team.winMatchQualsSum += m.scoreForTeam(team.num)
                                }else {
                                    team.lostMatchQualsCount++
                                    team.lostMatchQualsSum +=
                                        m.scoreForTeam(team.num)
                                }
                            }
                            // Find Team Color and Act Accordingly
                            let teamColor:NSString! = m.colorTeamIsOn(team.num)
                            if teamColor.isEqualToString("red") {
                                let score:Int =  mRaw["rs"] as! Int
                                team.sumOfMatches += score
                                comp.sumOfMatches += score
                                
                                // Find SP Points
                                if m.isQualsMatch() {
                                    comp.qualsCount++
                                    // if Team Won
                                    if m.didTeamWin(team.num) {
                                        // If the other alliance was a no-show, add red's score, else add the opponents score
                                        if m.blueScore.integerValue == 0 {
                                            team.spPointsSum += m.redScore.integerValue
                                            comp.spPointsSum += m.redScore.integerValue
                                        }else {
                                            team.spPointsSum += m.blueScore.integerValue
                                            comp.spPointsSum += m.blueScore.integerValue
                                        }
                                    }else {
                                        team.spPointsSum += m.redScore.integerValue
                                        comp.spPointsSum += m.redScore.integerValue
                                    }
                                }else {
                                    comp.elimCount++
                                }
                                // Check Highscore and Lowscores for team and comp
                                if m.redScore.integerValue > team.highestScore {
                                    team.highestScore = m.redScore.integerValue
                                }else if m.redScore.integerValue < team.lowestScore {
                                    team.lowestScore = m.redScore.integerValue
                                }
                                if m.redScore.integerValue > comp.highestScore {
                                    comp.highestScore = m.redScore.integerValue
                                }else if m.redScore.integerValue < comp.lowestScore {
                                    comp.lowestScore = m.redScore.integerValue
                                }
                            }else if teamColor.isEqualToString("blue") {
                                let score:Int = mRaw["bs"] as! Int
                                team.sumOfMatches += score
                                comp.sumOfMatches += score
                                // Find SP Points
                                if m.isQualsMatch() {
                                    comp.qualsCount++
                                    // if Team Won
                                    if m.didTeamWin(team.num) {
                                        // If the other alliance was a no-show, add red's score, else add the opponents score
                                        if m.redScore.integerValue == 0 {
                                            team.spPointsSum += m.blueScore.integerValue
                                            comp.spPointsSum += m.blueScore.integerValue
                                        }else {
                                            team.spPointsSum += m.redScore.integerValue
                                            
                                            comp.spPointsSum += m.redScore.integerValue
                                        }
                                        
                                    }else {
                                        team.spPointsSum += m.blueScore.integerValue
                                        comp.spPointsSum += m.blueScore.integerValue
                                    }
                                }else {
                                    comp.elimCount++
                                }
                                
                                // Check Highscore and Lowscores for team and comp
                                if m.blueScore.integerValue > team.highestScore {
                                    team.highestScore = m.blueScore.integerValue
                                }
                                if m.blueScore.integerValue < team.lowestScore {
                                    team.lowestScore = m.blueScore.integerValue
                                }
                                if m.blueScore.integerValue > comp.highestScore {
                                    comp.highestScore = m.blueScore.integerValue
                                }
                                if m.blueScore.integerValue < comp.lowestScore {
                                    comp.lowestScore = m.blueScore.integerValue
                                }
                            }else {
                                println("ERROR")
                            }
                            comp.matchCount++
                            team.matchCount++
                            comp.matches.addObject(m)
                            
                        }
                        team.compCount++
                        comp.orderMatches()
                        team.competitions.addObject(comp)
                        // Now awards!
                        var awardQuery = PFQuery(className:"Awards")
                        awardQuery.whereKey("compID", equalTo: compID)
                        awardQuery.whereKey("team", equalTo: team.num)
                        var results = awardQuery.findObjects()
                        if let resultsArray = results {
                            for result1 in resultsArray {
                                var result = result1 as! PFObject
                                var a: Award = Award()
                                a.award = result["name"] as! String
                                
                                var t:Team = Team()
                                t.num = result["team"] as! String
                                a.team = t
                                for c in team.competitions {
                                    if (c as! Competition).compID == (result["compID"] as! String) {
                                        a.comp = c.name
                                    }
                                }
                                team.awards.addObject(a)
                                team.awardCount++
                            }
                        }
                    }
                }
                
                }
                return team
        }
        
        func calculateQualCount() {
            for var i = 0; i < self.matches.count; i++ {
                var m: Match! = matches.objectAtIndex(i) as! Match
                if m.isQualsMatch() {
                    println("bleh")
                    self.qualCount++
                }
            }
            //println("\(self.num) had \(self.qualCount) matches")
        }
        
        func calculateStats(var max:NSInteger) {
            var curQualCount: NSInteger = 0
            self.orderMatches()
            for var i = 0; i < self.matches.count; i++ {
                var m: Match! = matches.objectAtIndex(i) as! Match
                println("\(m.name) \(self.num) \(curQualCount) \(max)")
                
                if m.isQualsMatch() && curQualCount < max {
                    self.qualCount++
                    curQualCount++
                    if m.didTeamTie(self.num) {
                        self.spPointsSum += m.scoreForTeam(self.num)
                        self.tieMatchQualsCount++
                        self.wp++
                    }else if m.didTeamWin(self.num) {
                        self.winMatchQualsCount++
                        self.wp += 2
                        if m.scoreForOpposingTeam(self.num) == 0 {
                            self.spPointsSum += m.scoreForTeam(self.num)
                            
                        }else {
                            self.spPointsSum += m.scoreForOpposingTeam(self.num)
                        }
                        
                    }else if !m.didTeamWin(self.num){
                        self.lostMatchQualsCount++
                        self.spPointsSum += m.scoreForTeam(self.num)
                        
                    }
                }
            }
        }
        
        func orderMatches() {
            var tempArray: NSMutableArray! = NSMutableArray()
            
            for var i = 0; i < matches.count; i++ {
                var m: Match! = matches.objectAtIndex(i) as! Match
                if m.isQualsMatch() {
                    tempArray.addObject(m)
                }
            }
            // Sort
            for (var i = 0; i < tempArray.count; i++) {
                var m: Match! = tempArray.objectAtIndex(i) as! Match
                for (var y = i; y > -1; y--) {
                    if (m.name.toInt()! < tempArray.objectAtIndex(y).name.toInt()!) {
                        tempArray.removeObjectAtIndex(y + 1)
                        tempArray.insertObject(m, atIndex: y)
                    }
                }
            }
            // QF
            for var i = 0; i < matches.count; i++ {
                var m: Match! = matches.objectAtIndex(i) as! Match as Match
                if m.name.rangeOfString("QF", options: nil, range: nil, locale: nil) != nil {
                    tempArray.addObject(m)
                }
            }
            for var i = 0; i < matches.count; i++ {
                var m: Match! = matches.objectAtIndex(i) as! Match as Match
                if m.name.rangeOfString("SF", options: nil, range: nil, locale: nil) != nil {
                    tempArray.addObject(m)
                }
            }
            for var i = 0; i < matches.count; i++ {
                var m: Match! = matches.objectAtIndex(i) as! Match as Match
                if m.name.rangeOfString("F", options: nil, range: nil, locale: nil) != nil && m.name.rangeOfString("SF", options: nil, range: nil, locale: nil) == nil && m.name.rangeOfString("Q", options: nil, range: nil, locale: nil) == nil{
                    tempArray.addObject(m)
                }
            }
            self.matches = tempArray;
            
        }
        
        // Date must be in yyyy-MM-dd
        // Order comps newest to oldest
        func orderCompetitions() {
            println("ORDERING")
            // Make formatter
            var formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            // Sort
            for (var i = 0; i < self.competitions.count; i++) {
                var c: Competition! = self.competitions.objectAtIndex(i) as! Competition
                for (var y = i; y > -1; y--) {
                    var cDate: NSDate
                    var yDate: NSDate
                    if c.date == "League" {
                        cDate = formatter.dateFromString("9999-12-12")!
                    }else {
                        cDate = formatter.dateFromString(c.date)!
                    }
                    
                    if (self.competitions.objectAtIndex(y) as! Competition).date == "League"{
                        yDate = formatter.dateFromString("9999-12-12")!
                    }else {
                        yDate = formatter.dateFromString((self.competitions.objectAtIndex(y) as! Competition).date)!
                    }
                    
                    
                    // Date comparision to compare current date and end date.
                    var dateComparisionResult:NSComparisonResult = cDate.compare(yDate)
                    if dateComparisionResult == NSComparisonResult.OrderedAscending {
                        
                        self.competitions.removeObjectAtIndex(y + 1)
                        self.competitions.insertObject(c, atIndex: y)
                    }
                }
            }
        }
}