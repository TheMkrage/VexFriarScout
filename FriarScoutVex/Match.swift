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
    
    func colorTeamIsOn(team: String!) -> NSString! {
        if team == red1 || team == red2 || team == red3 {
            return "red"
        }else if team == blue1 || team == blue2 || team == blue3 {
            return "blue"
        }
        return "none"
    }
}
