//
//  Team.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/3/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class Team: NSObject {
    
    var name:String! = ""
    var num: String! = ""
    var loc: String! = ""
    var org: String! = ""
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
    var lowestScore: NSInteger = 100000000
    var spPointsSum: NSInteger = 0
    var compCount: NSInteger = 0
    var awardCount: NSInteger = 0
    var qualCount: NSInteger = 0
    
    // For use with comp overview
    var matches:NSMutableArray! = NSMutableArray()
    
    var wp: NSInteger = 0
    
    func calculateQualCount() {
        for var i = 0; i < self.matches.count; i++ {
            var m: Match! = matches.objectAtIndex(i) as! Match
            if m.isQualsMatch() {
                self.qualCount++
            }
        }
        println("\(self.num) had \(self.qualCount) matches")
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
                if (getMatchNum(m.name as String) < getMatchNum(tempArray.objectAtIndex(y).name)) {
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
    
    func getMatchNum(str: String!) -> NSInteger {
        var temp = split(str) {$0 == " "}
        return temp[1].toInt()!
    }
    
    // Date must be in yyyy-MM-dd
    // Order comps newest to oldest
    func orderCompetitions() {
        // Make formatter
        var formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // Sort
        for (var i = 0; i < self.competitions.count; i++) {
            var c: Competition! = self.competitions.objectAtIndex(i) as! Competition
            for (var y = i; y > -1; y--) {
                var cDate: NSDate = formatter.dateFromString(c.date)!
                var yDate: NSDate = formatter.dateFromString((self.competitions.objectAtIndex(y) as! Competition).date)!
                // Date comparision to compare current date and end date.
                var dateComparisionResult:NSComparisonResult = cDate.compare(yDate)
                if dateComparisionResult == NSComparisonResult.OrderedDescending {
                    self.competitions.removeObjectAtIndex(y + 1)
                    self.competitions.insertObject(c, atIndex: y)
                }
            }
        }
        
    }

}
