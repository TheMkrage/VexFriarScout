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
    
    override func viewWillAppear(animated: Bool) {
        self.awardTable.reloadData()
    }
    
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
        var color:CGColor = UIColor.grayColor().CGColor
        var letter = String(Array(a.award)[0]).uppercaseString
        
        if a.award.lowercaseString.rangeOfString("skills") != nil {
            color = Colors.colorWithHexString("#FF6666").CGColor
        }else if a.award.lowercaseString.rangeOfString("champion") != nil {
            color = Colors.colorWithHexString("#80CCFF").CGColor
        }else if a.award.lowercaseString.rangeOfString("excellence") != nil {
            color = Colors.colorWithHexString("#CCB2FF").CGColor
        }else if a.award.lowercaseString.rangeOfString("tournament") != nil {
            color = Colors.colorWithHexString("#FFB280").CGColor
        }else {
            color = Colors.colorWithHexString("#99E699").CGColor
        }
        cell.contentView.addSubview(CircleView(frame: CGRectMake(10, 0, 61, 61), innerColor: color, rimColor: color, text: letter, font: UIFont(name: "HelveticaNeue-UltraLight", size: 30)!))
        cell.awardNameLabel.text = a.award
        cell.compNameLabel.text = a.team.num
        if indexPath.row % 2 == 0 {
            println("ROW: \(indexPath.row)")
            cell.backgroundColor = Colors.colorWithHexString("#f0f0f0")
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
}
