//
//  Competition.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/3/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class Competition: NSObject {
    var name: String! = ""
    var date: String! = ""
    var loc: String! = ""
    var season: String! = ""
    var gotTo: String! = ""
    
    var matches: NSMutableArray! = NSMutableArray()
    var awards: NSMutableArray! = NSMutableArray()
    
    var spPointsSum:NSInteger = 0
    var sumOfMatches: NSInteger = 0
    
    var matchCount: NSInteger = 0
    var elimCount: NSInteger = 0
    var qualsCount: NSInteger = 0
    
    var highestScore: NSInteger = 0
    var highestRowNum: NSInteger = 0
    var lowestScore: NSInteger = 100000
    var lowestRowNum: NSInteger = 0
    
    var teams: NSMutableArray! = NSMutableArray()
    
    func getSPAverage() -> NSInteger {
        if self.qualsCount != 0 {
            return self.spPointsSum/self.qualsCount
        }
        return 0;
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
        for var i = 0; i < matches.count; i++ {
            var m: Match! = matches.objectAtIndex(i) as! Match as Match
            if (m.blueScore.integerValue == self.highestScore || m.redScore.integerValue == self.highestScore) {
                self.highestRowNum = i
            }
            if (m.blueScore.integerValue == self.lowestScore || m.redScore.integerValue == self.lowestScore) {
                self.lowestRowNum = i
            }
            
        }
        
    }
    
    func getMatchNum(str: String!) -> NSInteger {
        var temp = split(str) {$0 == " "}
        return temp[1].toInt()!
    }
    
    // To be used when finding rankings,
    func addMatchToTeam(str: NSString!, m: Match!) {
        self.makeSureTeamExists(str)
        for (var i = 0; i < self.teams.count; i++) {
            var t: Team! = teams.objectAtIndex(i) as! Team
            // If this is our team
            if str.isEqualToString(t.num) {
                (teams.objectAtIndex(i) as! Team).matches.addObject(m)
            }
        }
    }
    
    func makeSureTeamExists(str: NSString!) {
        var found: Bool = false
        for (var i = 0; i < self.teams.count; i++) {
            var t: Team! = teams.objectAtIndex(i) as! Team
            // If this is our team
            if str.isEqualToString(t.num) {
                found = true
            }
        }
        if !found {
            var t: Team! = Team()
            t.num = str as String!
            self.teams.addObject(t)
        }
    }
    
   }
