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
    var lowestScore: NSInteger = 100000

    func getSPAverage() -> NSInteger {
        if self.qualsCount != 0 {
            return self.spPointsSum/self.qualsCount
        }
        return 0;
    }
    
    func orderMatches() {
        var tempArray: NSMutableArray! = NSMutableArray()
        
        for var i = 1; i < matches.count; i++ {
            var m: Match! = matches.objectAtIndex(i) as! Match as Match
            if m.name.rangeOfString("Qual", options: nil, range: nil, locale: nil) != nil {
                tempArray.addObject(m)
            }
        }
        for var i = 1; i < matches.count; i++ {
            var m: Match! = matches.objectAtIndex(i) as! Match as Match
            if m.name.rangeOfString("QF", options: nil, range: nil, locale: nil) != nil {
                tempArray.addObject(m)
            }
        }
        for var i = 1; i < matches.count; i++ {
            var m: Match! = matches.objectAtIndex(i) as! Match as Match
            if m.name.rangeOfString("SF", options: nil, range: nil, locale: nil) != nil {
                tempArray.addObject(m)
            }
        }
        for var i = 1; i < matches.count; i++ {
            var m: Match! = matches.objectAtIndex(i) as! Match as Match
            if m.name.rangeOfString("Final", options: nil, range: nil, locale: nil) != nil {
                tempArray.addObject(m)
            }
        }
        self.matches = tempArray;
    }
}
