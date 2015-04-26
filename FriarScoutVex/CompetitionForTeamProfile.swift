//
//  CompetitionForTeamProfile.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/21/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class CompetitionForTeamProfile: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var competition: String!
    var matches: NSMutableArray!
    
    override func viewDidLoad() {
        let ref = Firebase(url: "link\(competition)")
        ref.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot :FDataSnapshot!) -> Void in
       
        })
    }
    @IBOutlet var matchesTable: UITableView!
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "matches"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}
