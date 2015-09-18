//
//  OverviewTeamProfileViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 5/10/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class OverviewTeamProfileViewController: HasTeamViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var seasons = ["NBN","Skyrise","Toss Up", "Sack Attack"]
    @IBOutlet var scrollView: UIScrollView!
    var isBookmarked: Bool = false // Tells if current profile is bookmarked
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numLabel: UILabel!
    @IBOutlet var highestScoreLabel: UILabel!
    @IBOutlet var spAvgLabel: UILabel!
    @IBOutlet var lowScoreLabel: UILabel!
    @IBOutlet var rankingsLabel: UILabel!
    @IBOutlet var letterLabel: UILabel!
    
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var programmingSkillsScore: UILabel!
    @IBOutlet var robotSkillsScore: UILabel!
    @IBOutlet var seasonPicker: UIPickerView!
    
    // just default values
    var compCircle:CircleView = CircleView(frame: CGRectMake(50, 50, 80, 80))
    var awardCircle:CircleView = CircleView(frame: CGRectMake(50, 50, 80, 80))
    
    @IBOutlet var seasonPickerButton: UIButton!
    @IBAction func seasonPickerButton(sender: AnyObject) {
        sender.setTitle(self.team.season, forState: .Normal)
        println(self.team.season)
        if self.seasonPicker.hidden {
            self.seasonPicker.hidden = false
        }else {
            self.seasonPicker.hidden = true
        }
        
    }
    
    func alert(header:String!, withMemo memo:String!, withButtonText buttonText:String!) {
        let alertController = UIAlertController(title: header, message:
            memo, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion:  { () -> Void in
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    override func viewDidAppear(animated: Bool) {
        self.seasonPicker.hidden = true
        var row = 0
        for var i = 0; i < self.seasons.count; i++ {
            if self.seasons[i] == self.team.season {
                row = i
            }
        }
        self.seasonPicker.selectRow(row, inComponent: 0, animated: true)
        self.updateLabels()
    }
    
    var lineChart: LineChart!
    override func viewDidLoad() {
        
        self.seasonPickerButton.setTitle(self.team.season, forState: .Normal)
        var touch = UITapGestureRecognizer(target: self, action:"scrollTouchesBegan")
        self.scrollView.addGestureRecognizer(touch)
        self.seasonPicker.delegate = self
        self.drawBackground()
        self.findIfBookmarked()
        self.loadCompetitions()
        var x:HasTeamViewController = self.tabBarController?.viewControllers![1] as! HasTeamViewController!
        x.team = self.team as Team!
        var y:HasTeamViewController = self.tabBarController?.viewControllers![2] as! HasTeamViewController!
        y.team = self.team as Team!
        var z:HasTeamViewController = self.tabBarController?.viewControllers![3] as! HasTeamViewController!
        z.team = self.team as Team!
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
        chartRect.cornerRadius = 5
        let rightDivider = CAShapeLayer()
        rightDivider.bounds = CGRect(x: self.view.frame.width * (2/3), y: 200, width: 2, height: 55)
        rightDivider.position = CGPoint(x: self.view.frame.width * (2/3), y: 200)
        self.scrollView.layer.addSublayer(rightDivider)
        rightDivider.backgroundColor = UIColor.whiteColor().CGColor
        rightDivider.cornerRadius = 1
        let leftDivider = CAShapeLayer()
        leftDivider.bounds = CGRect(x: self.view.frame.width * (1/3), y: 200, width: 2, height: 55)
        leftDivider.position = CGPoint(x: self.view.frame.width * (1/3), y: 200)
        self.scrollView.layer.addSublayer(leftDivider)
        leftDivider.backgroundColor = UIColor.whiteColor().CGColor
        leftDivider.cornerRadius = 1
        
        let seasonDivider = CAShapeLayer()
        seasonDivider.bounds = CGRect(x: self.view.frame.width/2, y: self.rankingsLabel.frame.origin.y, width: 160, height: 3)
        seasonDivider.position = CGPoint(x: self.view.frame.width/2, y: chartRect.frame.origin.y + 115)
        self.scrollView.layer.addSublayer(seasonDivider)
        seasonDivider.backgroundColor = UIColor.darkGrayColor().CGColor
        seasonDivider.cornerRadius = 2
        
        let skillsChart = CAShapeLayer()
        skillsChart.bounds = CGRect(x: seasonDivider.frame.origin.x + 40, y: seasonDivider.frame.origin.y + 50, width: 50, height: 200)
        skillsChart.position = CGPoint(x: seasonDivider.frame.origin.x + 40, y: seasonDivider.frame.origin.y + 50)
        self.scrollView.layer.addSublayer(skillsChart)
        skillsChart.strokeColor = UIColor.grayColor().CGColor
        skillsChart.cornerRadius = 2
        skillsChart.lineWidth = 5.0
        
        var circle: CircleView = CircleView(frame: CGRectMake(10, 10, self.view.frame.width * (2/5), self.view.frame.width * (2/5)), text: self.team.numOnly, bottom: self.team.letterOnly, font: UIFont(name: "HelveticaNeue-UltraLight", size: 45)!)
        self.scrollView.addSubview(circle)
        //circle.animateCircle(1.0)
        
        self.compCircle = CircleView(frame: CGRectMake(leftDivider.frame.origin.x - 40, seasonDivider.frame.origin.y + 50, 80, 80), innerColor: UIColor.lightGrayColor().CGColor, rimColor: UIColor.lightGrayColor().CGColor, text: "NA", font: UIFont(name: "HelveticaNeue-UltraLight", size: 30)!)
        self.scrollView.addSubview(self.compCircle)
        self.compCircle.animateCircle(1.0)
        
        self.awardCircle = CircleView(frame: CGRectMake(compCircle.frame.origin.x, compCircle.frame.origin.y + 107, 80, 80), innerColor: UIColor.lightGrayColor().CGColor, rimColor: UIColor.lightGrayColor().CGColor, text: "NA", font: UIFont(name: "HelveticaNeue-UltraLight", size: 30)!)
        self.scrollView.addSubview(self.awardCircle)
        self.awardCircle.animateCircle(1.0)
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize.height = 700
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
        var skillsQuery = PFQuery(className: "rs")
        skillsQuery.whereKey("team", equalTo: self.team.num)
        skillsQuery.whereKey("season", equalTo: self.team.season)
        skillsQuery.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if let results = objects as? [PFObject] {
                if !results.isEmpty {
                    let pf = objects![0] as! PFObject
                    var x = pf["score"] as! NSInteger!
                    self.team.rs = "\(x)"
                    self.updateLabels()
                }
            }
        }
        skillsQuery = PFQuery(className: "ps")
        skillsQuery.whereKey("team", equalTo: self.team.num)
        skillsQuery.whereKey("season", equalTo: self.team.season)
        skillsQuery.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if let results = objects as? [PFObject] {
                if !results.isEmpty {
                    let pf = objects![0] as! PFObject
                    var x = pf["score"] as! NSInteger!
                    self.team.ps = "\(x)"
                    self.updateLabels()
                }
            }
        }
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
                self.team.statArray = newTeam["stats"] as! NSMutableArray
                self.nameLabel.text = self.team.name
                self.locationLabel.text = self.team.loc
                self.team.competitionIDs = newTeam["competitions"] as! NSMutableArray
                var query = PFQuery(className:"Competitions")
                query.whereKey("season", equalTo: self.team.season)
                println(self.team.num)
                query.whereKey("teams", equalTo: self.team.num)
                query.findObjectsInBackgroundWithBlock({ (results:[AnyObject]?, error:NSError?) -> Void in
                    if let x = results as? [PFObject] {
                        for result in x {
                            var comp: Competition = Competition()
                            comp.compID = result.objectId
                            comp.name = result["name"] as! String
                            var compID = result.objectId!
                            comp.date = result["date"] as! String
                            comp.loc = result["loc"] as! String
                            comp.season = result["season"] as! String
                            
                            for str in self.team.statArray {
                                // right string with stats
                                if str.containsString(comp.compID) {
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
                                    
                                }
                            }
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
                                let x =  mRaw["rs"] as! Int!
                                m.redScore = "\(x)"
                                let y = mRaw["bs"]as! Int!
                                m.blueScore = "\(y)"
                                m.name = mRaw["num"] as! String
                                m.name = m.name.stringByReplacingOccurrencesOfString(" ", withString: "")
                                if m.name.uppercaseString.rangeOfString("QF") != nil {
                                    m.name = m.name.stringByReplacingOccurrencesOfString("Q", withString: "")
                                    m.name = m.name.stringByReplacingOccurrencesOfString("F", withString: "")
                                    comp.qf.addObject(m)
                                    comp.sumOfQF += m.scoreForTeam(self.team.num)
                                    comp.sumOfElims += m.scoreForTeam(self.team.num)
                                }else if m.name.uppercaseString.rangeOfString("SF") != nil {
                                    m.name = m.name.stringByReplacingOccurrencesOfString("S", withString: "")
                                    m.name = m.name.stringByReplacingOccurrencesOfString("F", withString: "")
                                    comp.sf.addObject(m)
                                    comp.sumOfSF += m.scoreForTeam(self.team.num)
                                    comp.sumOfElims += m.scoreForTeam(self.team.num)
                                }else if m.name.uppercaseString.rangeOfString("F") != nil {
                                    m.name = m.name.stringByReplacingOccurrencesOfString("F", withString: "")
                                    comp.finals.addObject(m)
                                    comp.sumOfFinals += m.scoreForTeam(self.team.num)
                                    comp.sumOfElims += m.scoreForTeam(self.team.num)
                                }else {
                                    m.name = m.name.stringByReplacingOccurrencesOfString("Q", withString: "")
                                    comp.quals.addObject(m)
                                    comp.sumOfQuals += m.scoreForTeam(self.team.num)
                                }
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
                            comp.orderMatches()
                            self.team.competitions.addObject(comp)
                            self.updateLabels()
                            // Now awards!
                            var awardQuery = PFQuery(className:"Awards")
                            awardQuery.whereKey("compID", equalTo: compID)
                            awardQuery.whereKey("team", equalTo: self.team.num)
                            self.awardCircle.setText("0")
                            awardQuery.findObjectsInBackgroundWithBlock { ( results: [AnyObject]?, error: NSError?
                                ) -> Void in
                                if let resultsArray = results {
                                    for result1 in resultsArray {
                                        var result = result1 as! PFObject
                                        var a: Award = Award()
                                        a.award = result["name"] as! String
                                        
                                        var t:Team = Team()
                                        t.num = result["team"] as! String
                                        a.team = t
                                        for c in self.team.competitions {
                                            if (c as! Competition).compID == (result["compID"] as! String) {
                                                a.comp = c.name
                                            }
                                        }
                                        self.team.awards.addObject(a)
                                        self.team.awardCount++
                                        self.awardCircle.setText("\(self.team.awards.count)")
                                    }
                                }
                            }
                        }
                    }
                })
            }
            
        }
    }
    // Help Me
    @IBAction func spAvgHelp(sender: AnyObject) {
        self.alert("SP AVG", withMemo: "SP Avg represents the overall average of SP points a team obtains per competition.", withButtonText:"Thank You!")
    }
    
    func updateLabels() {
        println("bleH")
        self.compCircle.setText("\(self.team.competitions.count)")
        self.awardCircle.setText("\(self.team.awards.count)")
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
    
    func scrollTouchesBegan() {
        self.seasonPicker.hidden = true
        self.updateData()
    }
    
    func updateData() {
        var t = Team()
        t.num = self.team.num
        t.season = self.team.season
        self.team = t
        self.loadCompetitions()
        var x:HasTeamViewController = self.tabBarController?.viewControllers![1] as! HasTeamViewController!
        x.team = self.team as Team!
        var y:HasTeamViewController = self.tabBarController?.viewControllers![2] as! HasTeamViewController!
        y.team = self.team as Team!
        var z:HasTeamViewController = self.tabBarController?.viewControllers![3] as! HasTeamViewController!
        z.team = self.team as Team!
        self.updateLabels()
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return self.seasons[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.seasonPickerButton.setTitle( seasons[row], forState: .Normal)
        self.team.season = seasons[row]
        println(self.team.season)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.seasons.count
    }
}