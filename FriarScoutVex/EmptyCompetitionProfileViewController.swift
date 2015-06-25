
//
//  EmptyCompetitionProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 6/14/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class EmptyCompetitionProfileViewController: HasCompetitionViewController, UITableViewDelegate, UITableViewDataSource
{
    var name: String! = ""
    var season: String! = ""
    var teams:NSMutableArray = NSMutableArray()
    
    @IBOutlet var seasonLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var locLabel: UILabel!
    
    @IBOutlet var teamTabel: UITableView!
    
    override func viewDidLoad() {
         println("https://vexscoutcompetitions.firebaseio.com/\(self.comp.season)/\(self.comp.name)")
        self.teamTabel.delegate = self
        self.teamTabel.dataSource = self
        self.loadComp()
    }
    
    func loadComp() {
        let ref = Firebase(url: "https://vexscoutcompetitions.firebaseio.com/\(self.comp.season)/\(self.comp.name)")
        println("https://vexscoutcompetitions.firebaseio.com/\(self.comp.season)/\(self.comp.name)")
        ref.observeSingleEventOfType( FEventType.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
            
            self.comp.name = snapshot.value["name"] as! String
            self.comp.date = snapshot.value["date"] as! String
            self.comp.loc = snapshot.value["loc"] as! String
            self.comp.season = snapshot.value["season"] as! String
            self.seasonLabel.text = self.season
            self.locLabel.text = self.comp.loc
            self.dateLabel.text = self.comp.date
            var running: Bool = true
            for var i:Int = 0; running; i++ {
                if UInt(i) < snapshot.childSnapshotForPath("teams").childrenCount {
                    self.teams.addObject(snapshot.childSnapshotForPath("teams").value[i] as! String)
                    self.teamTabel.reloadData()
                    println(self.teams)
                }else {
                    running = false
                }
            }
        })
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Teams"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! UITabBarController
        // Set the title of the teamcontroller
        vc.title = "Team \(self.teams.objectAtIndex(indexPath.row) as? String)"
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
