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
}
