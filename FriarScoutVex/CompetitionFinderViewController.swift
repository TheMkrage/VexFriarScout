//
//  CompetitionFinderViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 9/24/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class CompetitionFinderViewController: UITableViewController,UISearchBarDelegate, UISearchDisplayDelegate {
    var curSeason = ""
    var searchID = 0
    var searchResults:[String] = []
    var comps:[SearchResults] = []
    var curLoc = ""
    
    struct SearchResults {
        var name: String!
        var additionalInfo: String!
        var isTeam: Bool!
        var comp:Competition!
    }
    
    func changeLoc(var loc:String!) {
        self.comps = []
        self.curLoc = loc
        // Find some comps
        var query = PFQuery(className: "Competitions")
        query.orderByAscending("date")
        query.whereKey("loc", equalTo: curLoc)
        query.whereKey("season", equalTo: self.curSeason)
        var arrayOfComps = query.findObjects() as! [PFObject]
        for x in arrayOfComps {
            
            var comp: Competition = Competition()
            comp.date = x["date"] as! String
            comp.name = x["name"] as! String
            comp.season = x["season"] as! String
            comp.compID = x.objectId
            var curResults = SearchResults(name: (x["name"] as! String), additionalInfo: "", isTeam: false, comp: comp)
            
            self.comps.append(curResults)
        }
        self.tableView.reloadData()

    }
    
    func updateSearchWithNewString(str:String!, id:Int) {
        
        // Find some comps
        var query = PFQuery(className: "Competitions")
        query.limit = 10
        query.whereKey("loc", containsString: str.uppercaseString)
        query.whereKey("season", equalTo: self.curSeason)
        if id != self.searchID {
            return
        }
        var arrayOfComps = query.findObjects() as! [PFObject]
        
        // self.updatingSerach = true
        self.searchResults = []
        
        for x in arrayOfComps {
            var found = false
            for y in self.searchResults {
                if y == x["loc"]! as! String {
                    found = true
                }
            }
            if !found {
                self.searchResults.append(x["loc"]! as! String)
            }
        }
        // self.updatingSerach = false
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
            self.searchID++
            self.updateSearchWithNewString(searchString, id: self.searchID)
            dispatch_async(dispatch_get_main_queue()) {
                self.searchDisplayController?.searchResultsTableView.reloadData()
            }
        }
        return false
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.isEqual(self.tableView) {
            self.moveToComp(self.comps[indexPath.row].comp)
        }else {
            self.changeLoc(self.searchResults[indexPath.row])
            self.searchDisplayController?.setActive(false, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView.isEqual(self.tableView) {
            var cell:UITableViewCell = UITableViewCell()
            cell.textLabel?.text = self.comps[indexPath.row].name
            return cell
        }else {
            var cell:UITableViewCell = UITableViewCell()
            cell.textLabel?.text = self.searchResults[indexPath.row]
            return cell
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.isEqual(self.tableView) {
            return self.comps.count
        }else {
            return self.searchResults.count
        }
    }
    
    
    func moveToComp(comp: Competition!) {
        if comp.date == "League" {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompFullProfile") as! UITabBarController
            // Set the title of the menuViewController
            vc.title = "\(comp.name)"
            // Destintation ViewController, set team
            let dest: OverviewCompetitionProfileViewController = vc.viewControllers?.first as! OverviewCompetitionProfileViewController
            dest.name = comp.name
            dest.comp.compID = comp.compID
            dest.season = comp.season
            // Present Profile
            self.showViewController(vc as UIViewController, sender: vc)
        }else {
            var formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            var cDate: NSDate = formatter.dateFromString(comp.date)!
            var dateComparisionResult:NSComparisonResult = cDate.compare(NSDate())
            if(dateComparisionResult == NSComparisonResult.OrderedDescending) {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("EmptyProfile") as! EmptyCompetitionProfileViewController
                // Set the title of the menuViewController
                vc.title = "\(comp.name)"
                vc.name = comp.name
                vc.season = comp.season
                vc.comp = comp
                // Destintation ViewController, set team
                
                // Present Profile
                self.showViewController(vc as UIViewController, sender: vc)
                
            }else {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("CompFullProfile") as! UITabBarController
                // Set the title of the menuViewController
                vc.title = "\(comp.name)"
                // Destintation ViewController, set team
                let dest: OverviewCompetitionProfileViewController = vc.viewControllers?.first as! OverviewCompetitionProfileViewController
                dest.name = comp.name
                dest.season = comp.season
                dest.comp.compID = comp.compID
                // Present Profile
                self.showViewController(vc as UIViewController, sender: vc)
            }
        }
    }
}
