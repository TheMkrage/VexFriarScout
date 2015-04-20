//
//  TeamProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/9/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class TeamProfileViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var competitionsTable: UITableView!

    var competitions: NSMutableArray!
    var team: NSString! = ""
    override func viewWillAppear(animated: Bool) {
        competitions = NSMutableArray();
        let ref = Firebase(url: "https://vexscout.firebaseio.com/teams/\(team)/comps")
        ref.observeSingleEventOfType(.ChildAdded, withBlock: { (snapshot:FDataSnapshot!) -> Void in
            println("Begin!")
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
            println(rest.value["name"])
                self.competitions.addObject(rest.value["name"]as! String)
                self.competitionsTable.reloadData()
            }
        
        })
    }
    override func viewDidLoad() {
        
        //set delegates and datasources
        self.competitionsTable.delegate = self
        self.competitionsTable.dataSource = self
        
    }
    
    //TABLE STUFF
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !(self.competitions != nil) {
            return 0
        }
        return competitions.count
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Competitions"
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Sorts numerically
        //sorted = self.sortArray(teams)
        
        // Creates cell and sets title to team num
        var cell = UITableViewCell()
        cell.textLabel?.text = self.competitions.objectAtIndex(indexPath.row) as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        /*let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfileTab") as! UITabBarController
        // Set the title of the menuViewController
        vc.title = "HELLO \(sorted.objectAtIndex(indexPath.row))"
        // Destintation ViewController, set team
        let dest: TeamProfileViewController = vc.viewControllers?.first as! TeamProfileViewController
        dest.team = sorted.objectAtIndex(indexPath.row)as! String
        // Present Profile
        self.showViewController(vc as UITabBarController, sender: vc)*/
    }

}
