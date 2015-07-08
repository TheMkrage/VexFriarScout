//
//  OverviewTeamProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/10/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class OverviewTeamProfileViewController: HasTeamViewController {
    @IBOutlet var scrollView: UIScrollView!
    var isBookmarked: Bool = false // Tells if current profile is bookmarked
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numLabel: UILabel!
    @IBOutlet var compCountLabel: UILabel!
    @IBOutlet var awardCountLabel: UILabel!
    @IBOutlet var highestScoreLabel: UILabel!
    @IBOutlet var spAvgLabel: UILabel!
    @IBOutlet var lowScoreLabel: UILabel!
    @IBOutlet var rankingsLabel: UILabel!
    
    @IBOutlet var favoriteButton: UIButton!
    func goHome() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func alert(header:String!, withMemo memo:String!, withButtonText buttonText:String!) {
        let alertController = UIAlertController(title: header, message:
            memo, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion:  { () -> Void in
            
        })
    }
    
    override func viewDidLoad() {
        var homeButton: UIBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: "goHome")
        self.findIfBookmarked()
        self.tabBarController?.navigationItem.rightBarButtonItem = homeButton
        self.title = "Team Overview"
        self.loadCompetitions()
        var x:HasTeamViewController = self.tabBarController?.viewControllers![1] as! HasTeamViewController!
        x.team = self.team as Team!
        var y:HasTeamViewController = self.tabBarController?.viewControllers![2] as! HasTeamViewController!
        y.team = self.team as Team!
        self.updateLabels()
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize.height = 450;
        self.scrollView.contentSize.width = self.view.frame.size.width;
    }
    
    func findIfBookmarked() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let curBookmarks = defaults.valueForKey("Bookmarks") as? NSArray {
            var book: NSMutableArray = NSMutableArray(array: curBookmarks)
            for (var i = 0; i < book.count; i++) {
                var curEl: NSDictionary = book.objectAtIndex(i) as! NSDictionary
                println(curEl)
                // if num and season equal current ones
                if (curEl.objectForKey("Num") as! NSString).isEqualToString(self.team.num) && (curEl.objectForKey("Season") as! NSString).isEqualToString(self.team.season){
                    isBookmarked = true
                    self.favoriteButton.setTitle("Unfav", forState: .Normal)
                    return
                }
            }
        }
        isBookmarked = false
        self.favoriteButton.setTitle("Fav", forState: .Normal)
    }
    
    func loadCompetitions() {
        println("Will Appear")
        self.team.competitions = NSMutableArray()
        
        // General Info
        let ref1 = Firebase(url: "https://vexscout.firebaseio.com/teams/\(team.num.uppercaseString)")
        ref1.observeSingleEventOfType(.Value, withBlock: { (snapshot:FDataSnapshot!) -> Void in
            // if the team does not exist
            if !snapshot.exists() {
                // Alert the user and bring them back to the main menu
                let alertController = UIAlertController(title: "Oh Dear!", message:
                    "Team \(self.team.num.uppercaseString) does not exist!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                return;
            }
            // Set the name, loc, and num vars and set text
            self.team.name = snapshot.value["name"] as! String
            self.team.loc = snapshot.value["loc"] as! String
            self.team.num = snapshot.value["num"] as! String
            self.nameLabel.text = self.team.name
            self.locationLabel.text = self.team.loc
            self.numLabel.text = self.team.num
            
        })
        // Competitions
        let refComp = Firebase(url: "https://vexscout.firebaseio.com/teams/\(team.num.uppercaseString)/comps/\(self.team.season)")
        println("https://vexscout.firebaseio.com/teams/\(team.num.uppercaseString)/comps/\(self.team.season)")
        refComp.observeEventType(.ChildAdded, withBlock: { snapshot in            println("Begin!")
            // Cycle through each competition
            println(snapshot.value.objectForKey("loc"))
            // let enumerator = snapshot.children
            
            // while let rest = enumerator.nextObject() as? FDataSnapshot {
            var comp: Competition = Competition()
            comp.name = snapshot.value["name"]as! String
            comp.date = snapshot.value["date"]as! String
            comp.loc = snapshot.value["loc"]as! String
            comp.season = snapshot.value["season"] as! String
            // Matches
            let ref = Firebase(url: "https://vexscout.firebaseio.com/teams/\(self.team.num.uppercaseString)/comps/\(self.team.season)/\(comp.name)/matches")
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                if snapshot.exists() {
                    let enum2 = snapshot.children
                    // Cycle through each Match
                    while let rest2 = enum2.nextObject() as? FDataSnapshot {
                        var m: Match = Match()
                        m.red1 = rest2.value["r0"] as! String
                        m.red2 = rest2.value["r1"] as! String
                        if let y = rest2.value["r2"]   as? String {
                            m.red3 =  rest2.value["r2"]  as! String
                        }
                        m.blue1 = rest2.value["b0"] as! String
                        m.blue2 = rest2.value["b1"] as! String
                        if let y = rest2.value["b2"]   as? String {
                            
                            m.blue3 =  rest2.value["b2"]  as! String
                        }
                        m.name = rest2.value["num"] as! String
                        let x =  rest2.value["rs"] as! Int!
                        m.redScore = "\(x)"
                        let y = rest2.value["bs"]as! Int!
                        m.blueScore = "\(y)"
                        
                        // Win Loss Counters
                        if m.didTeamTie(self.team.num) {
                            self.team.tieMatchCount++
                            self.team.tieMatchScoreSum += m.scoreForTeam(self.team.num)
                        }else if m.didTeamWin(self.team.num) {
                            self.team.winMatchCount++
                            self.team.winMatchScoreSum += m.scoreForTeam(self.team.num)
                        }else {
                            self.team.lostMatchCount++
                            self.team.lostMatchScoreSum +=
                                m.scoreForTeam(self.team.num)
                        }
                        // Now For Quals Matches
                        if m.isQualsMatch() {
                            self.team.qualCount++
                            // Win Loss Counters
                            if m.didTeamTie(self.team.num) {
                                self.team.tieMatchQualsCount++
                                self.team.tieMatchQualsSum += m.scoreForTeam(self.team.num)
                            }else if m.didTeamWin(self.team.num) {
                                self.team.winMatchQualsCount++
                                self.team.winMatchQualsSum += m.scoreForTeam(self.team.num)
                            }else {
                                self.team.lostMatchQualsCount++
                                self.team.lostMatchQualsSum +=
                                    m.scoreForTeam(self.team.num)
                            }
                        }
                        // Find Team Color and Act Accordingly
                        let teamColor:NSString! = m.colorTeamIsOn(self.team.num)
                        if teamColor.isEqualToString("red") {
                            let score:Int =  rest2.value["rs"] as! Int
                            self.team.sumOfMatches += score
                            comp.sumOfMatches += score
                            
                            // Find SP Points
                            if m.isQualsMatch() {
                                comp.qualsCount++
                                // if Team Won
                                if m.didTeamWin(self.team.num) {
                                    // If the other alliance was a no-show, add red's score, else add the opponents score
                                    if m.blueScore.integerValue == 0 {
                                        self.team.spPointsSum += m.redScore.integerValue
                                        comp.spPointsSum += m.redScore.integerValue
                                    }else {
                                        self.team.spPointsSum += m.blueScore.integerValue
                                        comp.spPointsSum += m.blueScore.integerValue
                                    }
                                }else {
                                    self.team.spPointsSum += m.redScore.integerValue
                                    comp.spPointsSum += m.redScore.integerValue
                                }
                            }else {
                                comp.elimCount++
                            }
                            // Check Highscore and Lowscores for team and comp
                            if m.redScore.integerValue > self.team.highestScore {
                                self.team.highestScore = m.redScore.integerValue
                            }else if m.redScore.integerValue < self.team.lowestScore {
                                self.team.lowestScore = m.redScore.integerValue
                            }
                            if m.redScore.integerValue > comp.highestScore {
                                comp.highestScore = m.redScore.integerValue
                            }else if m.redScore.integerValue < comp.lowestScore {
                                comp.lowestScore = m.redScore.integerValue
                            }
                        }else if teamColor.isEqualToString("blue") {
                            let score:Int = rest2.value["bs"] as! Int
                            self.team.sumOfMatches += score
                            comp.sumOfMatches += score
                            // Find SP Points
                            if m.isQualsMatch() {
                                comp.qualsCount++
                                // if Team Won
                                if m.didTeamWin(self.team.num) {
                                    // If the other alliance was a no-show, add red's score, else add the opponents score
                                    if m.redScore.integerValue == 0 {
                                        self.team.spPointsSum += m.blueScore.integerValue
                                        comp.spPointsSum += m.blueScore.integerValue
                                    }else {
                                        self.team.spPointsSum += m.redScore.integerValue
                                        
                                        comp.spPointsSum += m.redScore.integerValue
                                    }
                                    
                                }else {
                                    self.team.spPointsSum += m.blueScore.integerValue
                                    comp.spPointsSum += m.blueScore.integerValue
                                }
                            }else {
                                comp.elimCount++
                            }
                            
                            // Check Highscore and Lowscores for team and comp
                            if m.blueScore.integerValue > self.team.highestScore {
                                self.team.highestScore = m.blueScore.integerValue
                            }
                            if m.blueScore.integerValue < self.team.lowestScore {
                                self.team.lowestScore = m.blueScore.integerValue
                            }
                            if m.blueScore.integerValue > comp.highestScore {
                                comp.highestScore = m.blueScore.integerValue
                            }
                            if m.blueScore.integerValue < comp.lowestScore {
                                comp.lowestScore = m.blueScore.integerValue
                            }
                        }else {
                            println("ERROR")
                        }
                        comp.matchCount++
                        
                        self.team.matchCount++
                        comp.matches.addObject(m)
                    }
                }
                // Awards
                let refAward = Firebase(url: "https://vexscout.firebaseio.com/teams/\(self.team.num.uppercaseString)/comps/\(self.team.season)/\(comp.name)/awards")
                println("https://vexscout.firebaseio.com/teams/\(self.team.num.uppercaseString)/comps/\(self.team.season)/\(comp.name)/awards")
                refAward.observeSingleEventOfType(.Value, withBlock: { (snapshot: FDataSnapshot!) -> Void in
                    let x = NSNumber(unsignedLong: snapshot.childrenCount) as NSInteger
                    for var i = 0; i < x; i++ {
                        var a: Award = Award();
                        
                        a.award = snapshot.value[i] as! String!
                        a.comp = comp.name
                        a.team = self.team
                        
                        self.team.awards.addObject(a)
                        self.team.awardCount++
                        
                        self.awardCountLabel.text = "\(self.team.awardCount)"
                    }
                })
                self.team.compCount++
                self.compCountLabel.text = "\(self.team.compCount)"
                
                comp.orderMatches()
                //self.team.orderCompetitions()
                comp.season = self.team.season
                self.team.competitions.addObject(comp)
                self.updateLabels()
                
            })
            //  }
            self.updateLabels()
        })
        
        
    }
    // Help Me
    @IBAction func spAvgHelp(sender: AnyObject) {
        self.alert("SP AVG", withMemo: "SP Avg represents the overall average of SP points a team obtains per competition.", withButtonText:"Thank You!")
    }
    
    func updateLabels() {
        var sumOfsp: NSInteger = 0
        for c in self.team.competitions {
            sumOfsp += (c as! Competition).spPointsSum
        }
        if self.team.compCount != 0 {
            self.spAvgLabel.text = "\(sumOfsp/self.team.compCount)"
        }
        
        
        
        if self.team.matchCount != 0 {
            
            self.highestScoreLabel.text = "\(self.team.highestScore)"
            self.lowScoreLabel.text = "\(self.team.lowestScore)"
            
            var tie = ""
            var win = ""
            var loss = ""
            // Overall Record
            tie = "\(self.team.tieMatchCount)"
            win = "\(self.team.winMatchCount) - "
            loss = "\(self.team.lostMatchCount) - "
            self.rankingsLabel.text = "\(win)\(loss)\(tie)"
        }else {
            self.spAvgLabel.text = "NA"
            self.highestScoreLabel.text = "NA"
            self.lowScoreLabel.text = "NA"
            self.rankingsLabel.text = "NA"
            self.awardCountLabel.text = "NA"
        }
        /*if  self.team.matchCount != 0 {
        let x = "\(self.team.sumOfMatches/self.team.matchCount)"
        self.averageLabel.text = x;
        }*/
    }
    
    @IBAction func favorite(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if !isBookmarked {
            // Get the bookmarks array
            if let curBookmarks = defaults.valueForKey("Bookmarks") as? NSArray {
                var book: NSMutableArray = NSMutableArray(array: curBookmarks)
                // Add new team to bookmarks
                book.addObject(self.getCurrentDictionaryBookmark())
                defaults.setObject(book as NSArray, forKey: "Bookmarks")
                defaults.synchronize()
            }else { // This is the first bookmark
                var bookmarks: NSArray = [(self.getCurrentDictionaryBookmark())]
                defaults.setObject(bookmarks, forKey: "Bookmarks")
                defaults.synchronize()
            }
            self.isBookmarked = true
            self.favoriteButton.setTitle("Unfav", forState: .Normal)
        }else { // Remove the current profile from bookmarks
            let curBookmarks = defaults.valueForKey("Bookmarks") as? NSArray
            var book: NSMutableArray = NSMutableArray(array: curBookmarks!)
            // loop through and find item with num and season equal to current profile, find index
            var index = 0
            for (var i = 0; i < book.count; i++) {
                var curEl: NSDictionary = book.objectAtIndex(i) as! NSDictionary
                // if num and season equal current ones
                if (curEl.objectForKey("Num") as! NSString).isEqualToString(self.team.num) && (curEl.objectForKey("Season") as! NSString).isEqualToString(self.team.season){
                    index = i
                }
            }
            book.removeObjectAtIndex(index)
            // Update bookmarks
            defaults.setObject(book as NSArray, forKey: "Bookmarks")
            defaults.synchronize()
            self.isBookmarked = false
            self.favoriteButton.setTitle("Fav", forState: .Normal)
        }
        println(defaults.valueForKey("Bookmarks") as? NSArray)
    }
    
    func getCurrentDictionaryBookmark() -> NSDictionary {
        var curEl: NSMutableDictionary = NSMutableDictionary()
        curEl.setObject("Team", forKey: "Kind")
        curEl.setObject(self.team.num.uppercaseString, forKey: "Num")
        curEl.setObject(self.team.season, forKey: "Season")
        curEl.setObject(self.team.name, forKey: "Name")
        return curEl as NSDictionary
    }
}