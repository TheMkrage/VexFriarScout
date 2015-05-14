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

    
}
