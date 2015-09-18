//
//  MoreViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 9/6/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class MoreViewController: UITableViewController {
    var curSeason = ""
    var selections = ["Match Calculator", "NBN Rulebook", "Team 3309B Instagram"]
    
    override func viewDidLoad() {
        self.title = "More"
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = UITableViewCell()
        cell.textLabel?.text = selections[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selections.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch selections[indexPath.row] {
        case "Match Calculator" :
            var vc: MatchCalculatorViewController = self.navigationController?.viewControllers[0].storyboard?!.instantiateViewControllerWithIdentifier("MatchCalculator") as! MatchCalculatorViewController
            vc.curSeason = self.curSeason
            self.showViewController(vc, sender: self)
        case "NBN Rulebook" :
            var link:NSURL = NSURL(string: "http://content.vexrobotics.com/docs/vrc-nothing-but-net/VRC-Nothing-But-Net-Game-Manual-20150612.pdf")!
            if UIApplication.sharedApplication().canOpenURL(link) {
                UIApplication.sharedApplication().openURL(link)
            }else {
                println("ERROR")
            }

        case "Team 3309B Instagram" :
            var link:NSURL = NSURL(string: "instagram://user?username=Team3309B")!
            if UIApplication.sharedApplication().canOpenURL(link) {
                UIApplication.sharedApplication().openURL(link)
            }else {
                println("ERROR")
            }
        default:
            println("Error")
        }
    }
}
