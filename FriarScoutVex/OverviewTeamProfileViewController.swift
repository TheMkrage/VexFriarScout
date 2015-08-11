//
//  OverviewTeamProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/10/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

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
    @IBOutlet var letterLabel: UILabel!
    
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var programmingSkillsScore: UILabel!
    @IBOutlet var robotSkillsScore: UILabel!
    
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
    
    override func viewWillAppear(animated: Bool) {
        self.highestScoreLabel.center = CGPoint(x:(view.frame.width * (2/3)) + ((view.frame.width * (1/3))/2),y: self.highestScoreLabel.frame.origin.y)
    }
    
    override func viewDidLoad() {
        self.drawBackground()
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
    
    func drawBackground() {
        let center = view.center
        let bounds = CGRect(x: center.x, y: 200, width: self.view.frame.width - 16, height: 67)
        // Create CAShapeLayerS
        let chartRect = CAShapeLayer()
        chartRect.bounds = bounds
        chartRect.position = CGPoint(x: center.x, y: 200)
   self.scrollView.layer.addSublayer(chartRect)
        // 1
        chartRect.backgroundColor = UIColor.darkGrayColor().CGColor
        chartRect.cornerRadius = 20
        let rightDivider = CAShapeLayer()
        rightDivider.bounds = CGRect(x: self.view.frame.width * (2/3), y: 200, width: 5, height: 55)
        rightDivider.position = CGPoint(x: self.view.frame.width * (2/3), y: 200)
        self.scrollView.layer.addSublayer(rightDivider)
        rightDivider.backgroundColor = UIColor.whiteColor().CGColor
        rightDivider.cornerRadius = 5
        let leftDivider = CAShapeLayer()
        leftDivider.bounds = CGRect(x: self.view.frame.width * (1/3), y: 200, width: 5, height: 55)
        leftDivider.position = CGPoint(x: self.view.frame.width * (1/3), y: 200)
        self.scrollView.layer.addSublayer(leftDivider)
        leftDivider.backgroundColor = UIColor.whiteColor().CGColor
        leftDivider.cornerRadius = 5
        
        let seasonDivider = CAShapeLayer()
        seasonDivider.bounds = CGRect(x: self.view.frame.width/2, y: self.rankingsLabel.frame.origin.y, width: 160, height: 3)
        seasonDivider.position = CGPoint(x: self.view.frame.width/2, y: chartRect.frame.origin.y + 115)
        self.scrollView.layer.addSublayer(seasonDivider)
        seasonDivider.backgroundColor = UIColor.darkGrayColor().CGColor
        seasonDivider.cornerRadius = 2
        
        var circle: CircleView = CircleView(frame: CGRectMake(10, 10, self.view.frame.width * (2/5), self.view.frame.width * (2/5)))
        self.scrollView.addSubview(circle)
        circle.animateCircle(1.0)
        
        var compCircle = CircleView(frame: CGRectMake(leftDivider.frame.origin.x - 40, seasonDivider.frame.origin.y + 50, 80, 80), innerColor: UIColor.lightGrayColor().CGColor, rimColor: UIColor.lightGrayColor().CGColor)
        self.scrollView.addSubview(compCircle)
        compCircle.animateCircle(1.0)
        
        var awardCircle = CircleView(frame: CGRectMake(compCircle.frame.origin.x, compCircle.frame.origin.y + 107, 80, 80), innerColor: UIColor.lightGrayColor().CGColor, rimColor: UIColor.lightGrayColor().CGColor)
        self.scrollView.addSubview(awardCircle)
        awardCircle.animateCircle(1.0)
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize.height = 450
        self.scrollView.contentSize.width = self.view.frame.size.width
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
                    self.favoriteButton.setImage(UIImage(named: "FavoritedIcon.png"), forState: .Normal)
                    return
                }
            }
        }
        isBookmarked = false
        self.favoriteButton.setTitle("Fav", forState: .Normal)
    }
    
    func loadCompetitions() {
        var teamDigits:String = ""
        var teamLetters:String = ""
        let letters = NSCharacterSet.letterCharacterSet()
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        let characters = Array(self.team.num)
        for c in self.team.num.unicodeScalars {
            if letters.longCharacterIsMember(c.value) {
                teamLetters.append(c)
            } else if digits.longCharacterIsMember(c.value) {
                teamDigits.append(c)
            }
        }
        self.numLabel.text = teamDigits
        self.letterLabel.text = teamLetters
        var query = PFQuery(className:"Teams")
        query.whereKey("num", equalTo:self.team.num)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if objects?.count == 0 {
                // Alert the user and bring them back to the main menu
                let alertController = UIAlertController(title: "Oh Dear!", message:
                    "Team \(self.team.num.uppercaseString) does not exist!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                return;
            }
            if let newTeam: AnyObject = objects?[0] {
                // Find and set simple values
                self.team.name = newTeam["name"] as! String
                self.team.loc =  newTeam["loc"] as! String
                self.team.num = newTeam["num"] as! String
                self.nameLabel.text = self.team.name
                self.locationLabel.text = self.team.loc
                
                self.team.competitionIDs = newTeam["competitions"] as! NSMutableArray
                println(self.team.competitionIDs)
                // Find all comps tahat apply to current seaso
                for compID in self.team.competitionIDs {
                    var query = PFQuery(className:"Competitions")
                    query.whereKey("season", equalTo: self.team.season)
                    query.getObjectInBackgroundWithId(compID as! String) { ( result:PFObject?, error: NSError?
                        ) -> Void in
                        var comp: Competition = Competition()
                        comp.name = result!["name"] as! String
                        println(comp.name)
                        comp.date = result!["date"] as! String
                        comp.loc = result!["loc"] as! String
                        comp.season = result!["season"] as! String
                        // get matches for each comp
                        var matchIDQuery = PFQuery(className: "Matches")
                        matchIDQuery.whereKey("compID", equalTo: compID)
                        var matchesB0 = PFQuery(className: "Matches")
                        matchesB0.whereKey("b0", equalTo: self.team.num)
                        var matchesB1 = PFQuery(className: "Matches")
                        matchesB1.whereKey("b1", equalTo: self.team.num)
                        var matchesB2 = PFQuery(className: "Matches")
                        matchesB2.whereKey("b2", equalTo: self.team.num)
                        var matchesR0 = PFQuery(className: "Matches")
                        matchesR0.whereKey("r0", equalTo: self.team.num)
                        var matchesR1 = PFQuery(className: "Matches")
                        matchesR1.whereKey("r1", equalTo: self.team.num)
                        var matchesR2 = PFQuery(className: "Matches")
                        matchesR2.whereKey("r2", equalTo: self.team.num)
                        var matchesRaw = NSMutableArray()
                        matchesRaw.addObjectsFromArray( PFQuery.orQueryWithSubqueries([ matchesB0, matchesB1, matchesB2, matchesR0, matchesR1, matchesR2]).whereKey("compID", equalTo: compID).findObjects() as NSArray! as! [PFObject])
                        // Parse into Match objects
                        for mRaw in matchesRaw {
                            var m:Match = Match()
                            m.red1 = mRaw["r0"] as! String
                            m.red2 = mRaw["r1"] as! String
                            if let y = mRaw["r2"]   as? String {
                                m.red3 =  mRaw["r2"]  as! String
                            }
                            m.blue1 = mRaw["b0"] as! String
                            m.blue2 = mRaw["b1"] as! String
                            if let y = mRaw["b2"]   as? String {
                                
                                m.blue3 =  mRaw["b2"]  as! String
                            }
                            m.name = mRaw["num"] as! String
                            let x =  mRaw["rs"] as! Int!
                            m.redScore = "\(x)"
                            let y = mRaw["bs"]as! Int!
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
                                let score:Int =  mRaw["rs"] as! Int
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
                                let score:Int = mRaw["bs"] as! Int
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
                        self.team.compCount++
                        self.team.competitions.addObject(comp)
                        self.updateLabels()
                    }
                    var awardQuery = PFQuery(className:"Awards")
                    awardQuery.whereKey("compID", equalTo: compID)
                    awardQuery.whereKey("team", equalTo: self.team.num)
                    awardQuery.findObjectsInBackgroundWithBlock { ( results: [AnyObject]?, error: NSError?
                        ) -> Void in
                        if let result = results?.first as? PFObject {
                            var a: Award = Award()
                            a.award = result["name"] as! String
                            //a.comp = comp.name
                            var t:Team = Team()
                            t.num = result["team"] as! String
                            a.team = t
                            self.team.awards.addObject(a)
                            self.team.awardCount++
                            self.awardCountLabel.text = "\(self.team.awardCount)"
                            
                        }
                    }
                }
            }
        }
        
        
        
        /*
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
        }
        self.updateLabels()
        })
        self.updateLabels()*/
    }
    // Help Me
    @IBAction func spAvgHelp(sender: AnyObject) {
        self.alert("SP AVG", withMemo: "SP Avg represents the overall average of SP points a team obtains per competition.", withButtonText:"Thank You!")
    }
    
    func updateLabels() {
        println("bleH")
        self.compCountLabel.text = "\(self.team.compCount)"
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
        
        //Skills
        self.robotSkillsScore.text = self.team.rs
        self.programmingSkillsScore.text = self.team.ps
        
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
            self.favoriteButton.setImage(UIImage(named: "FavoritedIcon.png"), forState: .Normal)
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
            self.favoriteButton.setImage(UIImage(named: "UnfavoritedIcon.png"), forState: .Normal)
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