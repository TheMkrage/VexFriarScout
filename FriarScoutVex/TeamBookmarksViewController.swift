//
//  TeamBookmarksViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 7/7/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class TeamBookmarksViewController: UITableViewController,UITableViewDelegate,UITableViewDataSource {
    var bookmarks: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        self.getBookmarks()
    }
    
    func getBookmarks() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let curBookmarks = defaults.valueForKey("Bookmarks") as? NSArray {
            self.bookmarks = NSMutableArray(array: curBookmarks)
        }
        self.tableView.reloadData()
    }
    
    //TABLE STUFF
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bookmarks.count
    }
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Bookmarks"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num of bookmark
        var cell = tableView.dequeueReusableCellWithIdentifier("TeamBookmarkedCell") as! UITableViewCell
        cell.textLabel?.text = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Num") as? String
        /*if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = self.colorWithHexString("#f0f0f0")
        }else {
            cell.backgroundColor = UIColor.whiteColor()
        }*/
        
        return cell
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
}
