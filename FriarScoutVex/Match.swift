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
    var red1: String = ""
    var red2: String = ""
    var red3: String = ""
    var blue1: String = ""
    var blue2: String = ""
    var blue3: String = ""
    var redScore: String = ""
    var blueScore: String = ""
    
    // Return a string with the color depending on if a team was on the red or blue team, returns none if team was not in match
    func colorTeamIsOn(team: String!) -> NSString! {
        if team == red1 || team == red2 || team == red3 {
            return "red"
        }else if team == blue1 || team == blue2 || team == blue3 {
            return "blue"
        }
        return "none"
    }
    // Determines if Team team tied the match or not, defaults to false if team was not present in match
    func didTeamTie(team: String!) -> Bool {
        if redScore.toInt() == blueScore.toInt() {
            return true
        }
        return false
    }
    
    // Determines if Team team won the match or not, defaults to false if team was not present in match
    func didTeamWin(team: String!) -> Bool {
        if colorTeamIsOn(team).isEqualToString("red") {
            if redScore.toInt() > blueScore.toInt() {
                return true
            }
        }else if colorTeamIsOn(team).isEqualToString("blue") {
            if blueScore.toInt() > redScore.toInt() {
                return true
            }
        }
        return false
    }
    func isQualsMatch() -> Bool {
        if name.rangeOfString("Qual", options: nil, range: nil, locale: nil) != nil {
            return true
        }
        return false
    }
    
    func scoreForTeam(team: String) -> NSInteger {
        if colorTeamIsOn(team).isEqualToString("red") {
            return redScore.toInt()!
        }else if colorTeamIsOn(team).isEqualToString("blue") {
            return blueScore.toInt()!
        }
        return 0
    }
    
    func scoreForOpposingTeam(team: String) -> NSInteger {
        if colorTeamIsOn(team).isEqualToString("red") {
            return blueScore.toInt()!
        }else if colorTeamIsOn(team).isEqualToString("blue") {
            return redScore.toInt()!
        }
        return 0
    }
}
