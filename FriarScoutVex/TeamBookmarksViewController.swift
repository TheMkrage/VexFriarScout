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
    
    override func viewWillAppear(animated: Bool) {
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
        return "Favorites"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num of bookmark
        var cell = tableView.dequeueReusableCellWithIdentifier("TeamBookmarkedCell") as! TeamBookmarkCell
        var team = (self.bookmarks.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("Num") as! String
        cell.teamLabel.text = "Team \(team)"
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
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! UITabBarController
        // Destintation ViewController, set team
        let dest: OverviewTeamProfileViewController = vc.viewControllers?.first as! OverviewTeamProfileViewController
        var team2: Team! = Team()
        team2.num = teamDic.objectForKey("Num") as! String!
        team2.season = teamDic.objectForKey("Season") as! String!
        dest.team = team2
        // Set the title of the menuViewController
        vc.title = "Team \(team2.num)"
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
    }
}
