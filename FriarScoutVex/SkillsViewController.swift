//
//  SkillsViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 6/18/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class SkillsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Season for URL
    var season:String! = ""
    // Arrays for data
    var rs:NSMutableArray = NSMutableArray()
    var ps:NSMutableArray = NSMutableArray()
    // Array table uses
    var curSkills:NSMutableArray = NSMutableArray()
    // Table
    @IBOutlet var skillsTable: UITableView!

    override func viewDidLoad() {
        self.skillsTable.delegate = self
        self.skillsTable.dataSource = self
        self.loadSkills()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.skillsTable.reloadData()
    }
    
 
    
    // Gets and stores skills data in two arrays (ps and rs)
    func loadSkills() {
        // Robot Skills
        var ref: Firebase = Firebase(url:"https://vexscoutcompetitions.firebaseio.com/\(self.season)/rs")
        ref.queryLimitedToFirst(50).observeEventType(.ChildAdded, withBlock: { snapshot in
            var s:Skills = Skills()
            s.rank = snapshot.value["rank"] as! String
            s.team = snapshot.value["team"] as! String
            s.score = snapshot.value["score"] as! String
            self.rs.addObject(s)
            self.curSkills = self.rs
            self.skillsTable.reloadData()
        })
    }
    
    // Table Datasource and Delegate
    // Creates cells
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:SkillsCell = tableView.dequeueReusableCellWithIdentifier("skillsCell") as! SkillsCell
        var s: Skills = self.curSkills.objectAtIndex(indexPath.row) as! Skills
        cell.rankLabel.text = "\(s.rank)."
        cell.scoreLabel.text = "\(s.score)"
        cell.teamLabel.text = "\(s.team)"
        if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = self.colorWithHexString("#e0e0e0")
        }else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.curSkills.count
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
