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
    var sorted: NSArray!
    override func viewWillAppear(animated: Bool) {
        self.teams = NSMutableArray()
        var unsortedTeams = NSMutableArray()
        // Connect and order by key to place in array
        let ref = Firebase(url: "https://vexscout.firebaseio.com/teams")
        // Add all the values to an array
        ref.queryOrderedByValue().observeEventType(.ChildAdded, withBlock: { snapshot -> Void in
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
        
        // Sorts numerically
        sorted = self.sortArray(teams)
        
        // Creates cell and sets title to team num
        var cell = UITableViewCell()
        cell.textLabel?.text = sorted.objectAtIndex(indexPath.row) as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfileTab") as! UITabBarController
        // Set the title of the menuViewController
        vc.title = "HELLO \(sorted.objectAtIndex(indexPath.row))"
        // Destintation ViewController, set team
        let dest: TeamProfileViewController = vc.viewControllers?.first as! TeamProfileViewController
        dest.team = sorted.objectAtIndex(indexPath.row)as! String
        // Present Profile
        self.showViewController(vc as UITabBarController, sender: vc)
    }
    
    // Sorts array by numbers of each string
    func sortArray(array: NSMutableArray) -> NSArray {
        let sortedArray = array.sortedArrayUsingComparator {
            (str1, str2) -> NSComparisonResult in
            let one = str1 as! NSString
            let two = str2 as! NSString
            return one.stringByTrimmingCharactersInSet(NSCharacterSet.letterCharacterSet()).compare(two.stringByTrimmingCharactersInSet(NSCharacterSet.letterCharacterSet()))
        }
        println(sortedArray)
        return sortedArray
    }
}
