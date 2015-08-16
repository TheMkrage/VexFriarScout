//
//  Match.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/26/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class Match: NSObject {
    var name: String = ""
    var red1: NSString = ""
    var red2: NSString = ""
    var red3: NSString = ""
    var blue1: NSString = ""
    var blue2: NSString = ""
    var blue3: NSString = ""
    var redScore: NSString = ""
    var blueScore: NSString = ""
    
    // Return a string with the color depending on if a team was on the red or blue team, returns none if team was not in match
    func colorTeamIsOn(team: String!) -> NSString! {
        if team == red1 || team == red2 || team == red3 {
            return "red"
        }else if team == blue1 || team == blue2 || team == blue3 {
            return "blue"
        }
        return "none"
    }
    
    func colorTeamWon() -> NSString! {
        if self.redScore.integerValue > self.blueScore.integerValue{
            return "red"
        }else if self.redScore.integerValue < self.blueScore.integerValue {
            return "blue"
        }
        return "tie"

    }
    // Determines if Team team tied the match or not, defaults to false if team was not present in match
    func didTeamTie(team: String!) -> Bool {
        if redScore.integerValue == blueScore.integerValue {
            return true
        }
        return false
    }
    
    // Determines if Team team won the match or not, defaults to false if team was not present in match
    func didTeamWin(team: String!) -> Bool {
        if colorTeamIsOn(team).isEqualToString("red") {
            if redScore.integerValue > blueScore.integerValue {
                return true
            }
        }else if colorTeamIsOn(team).isEqualToString("blue") {
            if blueScore.integerValue > redScore.integerValue {
                return true
            }
        }
        return false
    }
    func isQualsMatch() -> Bool {      
        if name.rangeOfString("-", options: nil, range: nil, locale: nil) == nil{
            return true
        }
        return false
    }
    
    func scoreForTeam(team: String) -> NSInteger {
        if colorTeamIsOn(team).isEqualToString("red") {
            return redScore.integerValue
        }else if colorTeamIsOn(team).isEqualToString("blue") {
            return blueScore.integerValue
        }
        return 0
    }
    
    func scoreForOpposingTeam(team: String) -> NSInteger {
        if colorTeamIsOn(team).isEqualToString("red") {
            return blueScore.integerValue
        }else if colorTeamIsOn(team).isEqualToString("blue") {
            return redScore.integerValue
        }
        return 0
    }
}
