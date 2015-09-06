
//
//  EmptyCompetitionProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 6/14/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class EmptyCompetitionProfileViewController: HasCompetitionViewController, UITableViewDelegate, UITableViewDataSource
{
    var name: String! = ""
    var season: String! = ""
    var teams:NSMutableArray = NSMutableArray()
    
    @IBOutlet var eventNameTitleLabel: UILabel!
    @IBOutlet var seasonLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var locLabel: UILabel!
    
    @IBOutlet var teamTabel: UITableView!
    
    override func viewDidLoad() {
        self.teamTabel.delegate = self
        self.teamTabel.dataSource = self
        self.loadComp()
    }
    
    func loadComp() {
        var query = PFQuery(className:"Competitions")
        println(self.comp.compID as String)
        query.getObjectInBackgroundWithId(self.comp.compID as String) {
            (object: PFObject?, error:NSError?) -> Void in
            // reassurance
            if let x = object!["name"] as? String {
                self.comp.name = x
            }else{
                let alertController = UIAlertController(title: "Well, this is awkard!", message:
                    "I can't seem to find this competition! It isn't in our database... Hey it happens" , preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                return
            }
            self.comp.name = object!["name"] as! String
            self.comp.date = object!["date"] as! String
            self.comp.loc = object!["loc"] as! String
            self.comp.season = object!["season"] as! String
            self.teams = object!["teams"] as! NSMutableArray
            self.comp.compID = object!.objectId
            self.seasonLabel.text = self.season
            self.dateLabel.text = self.comp.date
            self.locLabel.text = self.comp.loc
            self.eventNameTitleLabel.text = self.comp.name
            self.teamTabel.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Teams"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! UITabBarController
        // Set the title of the teamcontroller
        vc.title = "Team \(self.teams.objectAtIndex(indexPath.row) as! String)"
        // Destintation ViewController, set team
        let dest: OverviewTeamProfileViewController = vc.viewControllers?.first as! OverviewTeamProfileViewController
        
        var t: Team! = Team()
        t.season = self.comp.season
        t.num = self.teams.objectAtIndex(indexPath.row) as! String
        dest.team = t
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Creates cell and sets title to team num
        var cell = tableView.dequeueReusableCellWithIdentifier("teamCell") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "teamCell")
        }
        cell!.textLabel!.text = self.teams.objectAtIndex(indexPath.row) as? String
        if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell!.backgroundColor = self.colorWithHexString("#f0f0f0")
        }else {
            cell!.backgroundColor = UIColor.whiteColor()
        }

        return cell!
}
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teams.count
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
