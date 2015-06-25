//
//  AwardsCompetitionProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/17/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class AwardsCompetitionProfileViewController: HasCompetitionViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var awardTable: UITableView!
    
    override func viewDidLoad() {
        self.awardTable.delegate = self
        self.awardTable.dataSource = self;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Awards"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! UITabBarController
        // Set the title of the teamcontroller
        vc.title = "Team \((self.comp.awards.objectAtIndex(indexPath.row) as! Award).team.num)"
        // Destintation ViewController, set team
        let dest: OverviewTeamProfileViewController = vc.viewControllers?.first as! OverviewTeamProfileViewController
       
        var t: Team! = (self.comp.awards.objectAtIndex(indexPath.row) as! Award).team
        t.season = self.comp.season
        dest.team = t
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("AwardCell") as! AwardCell
        
        var a: Award = self.comp.awards.objectAtIndex(indexPath.row) as! Award
        cell.awardNameLabel.text = a.award
        cell.compNameLabel.text = a.team.num
        if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = self.colorWithHexString("#f0f0f0")
        }else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        println(a.award)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comp.awards.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(advance(cString.startIndex, 1))
        }
        
        if (count(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

}
