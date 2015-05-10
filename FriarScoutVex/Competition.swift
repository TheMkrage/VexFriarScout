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
    var highestScore: String! = ""
    var matches: NSMutableArray! = NSMutableArray()
    var awards: NSMutableArray! = NSMutableArray()
}
