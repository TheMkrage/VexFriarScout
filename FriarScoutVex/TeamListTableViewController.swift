//
//  TeamListTableViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/8/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class TeamListTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    var teams: NSMutableArray!
    override func viewWillAppear(animated: Bool) {
        self.teams = NSMutableArray()
        var unsortedTeams = NSMutableArray()
        // Connect and order by key to place in array
        let ref = Firebase(url: "https://vexscout.firebaseio.com/skyrise/teams")
         ref.queryOrderedByValue().observeEventType(.ChildAdded, withBlock: { snapshot -> Void in
            var curTeam = snapshot.key
            println(curTeam.stringByTrimmingCharactersInSet(.decimalDigitCharacterSet()))
            self.teams.addObject(snapshot.key as NSString)
            self.tableView.reloadData()
         })
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell.textLabel?.text = teams.objectAtIndex(indexPath.row) as NSString
        return cell
    }
}
