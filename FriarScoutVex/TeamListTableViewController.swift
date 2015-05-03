//
//  TeamListTableViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/8/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//
/*
import UIKit

class TeamListTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    var teams: NSMutableArray!
    var sorted: NSArray!
    var controller: UISearchController!
    override func viewWillAppear(animated: Bool) {
        self.teams = NSMutableArray()
        var unsortedTeams = NSMutableArray()
        // Connect and order by key to place in array
        let ref = Firebase(url: "https://vexscout.firebaseio.com/teams")
        println("Starting Search")
        // Add all the values to an array
        ref.queryStartingAtValue("101").queryEndingAtValue("101~").observeEventType(.ChildAdded, withBlock: { snapshot -> Void in
            self.teams.addObject(snapshot.key as NSString)
            self.tableView.reloadData()
            println("adding \(snapshot.key)");
            }, withCancelBlock: { error in
                println(error.description)
        })
    }
    
    override func viewDidLoad() {
        // Init Search Bar on Table
        controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.searchBarStyle = .Minimal
        controller.searchBar.sizeToFit()
        self.tableView.tableHeaderView = controller.searchBar
       
        //self.definesPresentationContext = true;

    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !(teams != nil) {
            return 0
        }
        return teams.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Sorts numerically
        //sorted = self.sortArray(teams)
        
        // Creates cell and sets title to team num
        var cell = UITableViewCell()
        cell.textLabel?.text = self.teams.objectAtIndex(indexPath.row) as? String
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
    
    
    func filterContentForSearchText(searchText: String) {
        let ref = Firebase(url: "https://vexscout.firebaseio.com/teams")
        // Add all the values to an array
        self.teams = NSMutableArray();
        var lim = UInt(2)
        ref.queryLimitedToFirst(lim).observeEventType(.ChildAdded, withBlock: { snapshot -> Void in
            self.teams.addObject(snapshot.key as NSString)
            self.tableView.reloadData()
            println("adding \(snapshot.key)");
        })

    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        var searchText: String?
        searchText = searchController.searchBar.text;
        if (searchText != nil) {
            self.filterContentForSearchText(searchText!);
        }
    }
    
    
    
    /*func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.updateSearchResultsForSearchController(self.searchController);
    }*/
    // Sorts array by numbers of each string
    func sortArray(array: NSMutableArray) -> NSArray {
        let sortedArray = array.sortedArrayUsingComparator {
            (str1, str2) -> NSComparisonResult in
            let one = str1 as! NSString
            let two = str2 as! NSString
            println("\(one) is compared than \(two)")
            return one.stringByTrimmingCharactersInSet(NSCharacterSet.letterCharacterSet()).compare(two.stringByTrimmingCharactersInSet(NSCharacterSet.letterCharacterSet()))
        }
        println(sortedArray)
        return sortedArray
    }
}*/
