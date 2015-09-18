//
//  MatchCalculatorViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 9/6/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

extension Int {
    func format(f: String) -> String {
        return NSString(format: "%\(f)d", self) as String
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

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
        println("BEGAN CALC")
        self.statsArray = []
        self.teams = []
        self.done = 0
        self.blueOPRSum = 0.0
        self.blueDPRSum = 0.0
        self.redOPRSum = 0.0
        self.redDPRSum = 0.0
        self.totalDPR = 0.0
        self.totalOPR = 0.0
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
            println(curTeam.num.uppercaseString)
            query.whereKey("num", equalTo:curTeam.num.uppercaseString)
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                println("beginning loaded team section")
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
                    println("THERE IS A RESULTS")
                    // Find and set simple values
                    var stats = newTeam["stats"] as! NSMutableArray
                    
                    var query = PFQuery(className:"Competitions")
                    query.whereKey("season", equalTo: self.curSeason)
                    println(curTeam.num)
                    query.whereKey("teams", equalTo: curTeam.num.uppercaseString)
                    query.findObjectsInBackgroundWithBlock({ (results:[AnyObject]?, error:NSError?) -> Void in
                        println(stats)
                        //println(results)
                        if let x = results as? [PFObject] {
                            println("COMP IS RESULTS")
                            for result in x {
                                var comp: Competition = Competition()
                                var compID = result.objectId!
                                //println(stats)
                                for str in stats {
                                    // right string with stats
                                    println("cur\(str)")
                                    if (str as! NSString).containsString(compID) {
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
                                        println("adding \(array)")
                                        curTeam.statArray.addObject(array)
                                    }
                                }
                            }
                        }
                        self.done++
                        println("done2:\(self.done)")
                        if self.done == 8 {
                            self.updateLabels()
                        }

                    })
                }
                self.done++
                println("done2:\(self.done)")
                if self.done == 8 {
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
            println(team.statArray)
            for curArr in (team.statArray) {
                println(curArr[1].doubleValue)
                avgOPR = avgOPR + curArr[1].doubleValue
                avgDPR = avgDPR + curArr[2].doubleValue
            }
            if team.statArray.count != 0 {
                avgOPR /= Double(team.statArray.count)
                avgDPR /= Double(team.statArray.count)
            }else {
                avgOPR = 0
                avgDPR = 0
                let alertController = UIAlertController(title: "Oh Dear!", message:
                    "A team that you listed has not competed yet! For now, most of their stats will be 0.  This will affect predictions...", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Oh, Ok...", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                })

            }
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
        println("HELLSFDAF")
        var bluePercent1 = Double(((self.blueOPRSum - self.redDPRSum)/totalOffset) * 100).format("3.2")
        var redPercent1 = Double(((self.redOPRSum - self.blueDPRSum)/totalOffset) * 100).format("3.2")
        self.bluePercent.text = "\(bluePercent1)%"
        self.redPercent.text = "\(redPercent1)%"
        
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
