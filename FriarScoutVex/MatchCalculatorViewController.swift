//
//  MatchCalculatorViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 9/6/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class MatchCalculatorViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var predict: UIButton!
    @IBOutlet var blueTeam1TextField: UITextField!
    @IBOutlet var blueTeam2TextField: UITextField!
    @IBOutlet var redTeam1TextField: UITextField!
    @IBOutlet var redTeam2TextField: UITextField!
    @IBOutlet var bluePercent: UILabel!
    @IBOutlet var redPercent: UILabel!
    
    var teams:[Team] = []
    var statsArray = []
    
    var curSeason = ""
    var done = 0
    
    var blueOPRSum = 0.0
    var blueDPRSum = 0.0
    var redOPRSum = 0.0
    var redDPRSum = 0.0
    
    var totalOPR = 0.0
    var totalDPR = 0.0
    
    override func viewDidLoad() {
        self.blueTeam1TextField.delegate = self
        self.blueTeam2TextField.delegate = self
        self.redTeam1TextField.delegate = self
        self.redTeam2TextField.delegate = self
    }
    
    @IBAction func predictOut(sender: AnyObject) {
        var blueTeam1 = Team()
        blueTeam1.num = self.blueTeam1TextField.text
        var blueTeam2 = Team()
        blueTeam2.num = self.blueTeam2TextField.text
        var redTeam1 = Team()
        redTeam1.num = self.redTeam1TextField.text
        var redTeam2 = Team()
        redTeam2.num = self.redTeam2TextField.text
        self.teams = [blueTeam1, blueTeam2, redTeam1, redTeam2]
        for curTeam in self.teams {
            var query = PFQuery(className:"Teams")
            query.whereKey("num", equalTo:curTeam.num)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                if objects?.count == 0 {
                    // Alert the user and bring them back to the main menu
                    let alertController = UIAlertController(title: "Oh Dear!", message:
                        "Team \(curTeam.num.uppercaseString) does not exist!", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                    return
                }
                if let newTeam: AnyObject = objects?[0] {
                    // Find and set simple values
                    var stats = newTeam["stats"] as! NSMutableArray
                    var query = PFQuery(className:"Competitions")
                    query.whereKey("season", equalTo: self.curSeason)
                    query.whereKey("teams", equalTo: curTeam)
                    query.findObjectsInBackgroundWithBlock({ (results:[AnyObject]?, error:NSError?) -> Void in
                        if let x = results as? [PFObject] {
                            for result in x {
                                var comp: Competition = Competition()
                                var compID = result.objectId!
                             
                                for str in stats {
                                    // right string with stats
                                    if (str as! NSString).containsString(comp.compID) {
                                        println(str)
                                        var array: [String] = split(str as! String) {$0 == "+"}
                                        println(array)
                                        
                                        if (array[1] as NSString? != nil) {
                                            comp.opr = CGFloat((array[1] as NSString).floatValue)
                                        }
                                        if array[2] as NSString? != nil {
                                            comp.dpr = CGFloat((array[2] as NSString).floatValue)
                                        }
                                        if array[3] as NSString? != nil {
                                            comp.ccwm = CGFloat((array[3] as NSString).floatValue)
                                        }
                                        curTeam.statArray.addObject(array)
                                    }
                                }
                            }
                        }
                    })
                }
            self.done++
                if self.done == 4 {
                    self.updateLabels()
                }
            }
        }
    }
    
    func updateLabels() {
        for var i = 0; i < self.teams.count; i++ {
            var team = self.teams[i]
            var avgOPR = 0.0
            var avgDPR = 0.0
            for curArr in (team.statArray) {
                avgOPR = avgOPR + curArr[1].doubleValue
                avgDPR = avgDPR + curArr[2].doubleValue
            }
            avgOPR /= Double(team.statArray.count)
            avgDPR /= Double(team.statArray.count)
            if i == 0 || i == 1 {
                self.blueDPRSum += avgDPR
                self.blueOPRSum += avgOPR
            }else {
                self.redDPRSum += avgDPR
                self.redOPRSum += avgOPR
            }
            self.totalOPR += avgOPR
            self.totalDPR += avgOPR
            
        }
        var totalOffset = (self.redOPRSum - self.blueDPRSum) + (self.blueOPRSum - self.redDPRSum)
        self.bluePercent.text = "\((self.blueOPRSum - self.redDPRSum)/totalOffset)"
        self.redPercent.text = "\((self.redOPRSum - self.blueDPRSum)/totalOffset)"
        
    }
    
    // End editing if user taps off textfield
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // Text Field Delegate
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    
}
