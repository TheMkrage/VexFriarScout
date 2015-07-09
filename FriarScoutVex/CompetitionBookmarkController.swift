//
//  CompetitionBookmarkController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 7/8/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class CompetitionBookmarkController: UITableViewController, UITableViewDelegate,UITableViewDataSource {
    var bookmarks: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        self.getBookmarks()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.getBookmarks()
    }
    
    func getBookmarks() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let curBookmarks = defaults.valueForKey("Bookmarks Comp") as? NSArray {
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
        var cell = tableView.dequeueReusableCellWithIdentifier("CompBookmarkedCell") as! TeamBookmarkCell
        var team = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Name") as! String
        cell.teamLabel.text = "\(team)"
        cell.seasonLabel.text = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Season") as? String
        /*if indexPath.row % 2 == 0 {
        println("ROW: \(indexPath.row)")
        cell.backgroundColor = self.colorWithHexString("#f0f0f0")
        }else {
        cell.backgroundColor = UIColor.whiteColor()
        }*/
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var teamDic: NSDictionary = self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompFullProfile") as! UITabBarController
        // Set the title of the menuViewController
        
        // Destintation ViewController, set team
        let dest: OverviewCompetitionProfileViewController = vc.viewControllers?.first as! OverviewCompetitionProfileViewController
        dest.name = teamDic.objectForKey("Name") as! String!
        dest.season = teamDic.objectForKey("Season") as! String!
        vc.title = "\(dest.name)"
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)

    }
}
