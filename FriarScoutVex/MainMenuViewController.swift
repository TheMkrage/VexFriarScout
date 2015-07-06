//
//  MainMenuViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/8/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController, UITextFieldDelegate, AKPickerViewDataSource, AKPickerViewDelegate {
    // Every possible season
    let seasons = ["NBN", "Skyrise"]
    var season: NSString = "NBN"
    // Input
    @IBOutlet var seasonPicker: AKPickerView!
    @IBOutlet var TeamTextField: UITextField!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var visitProfileButton: UIButton!
    
    struct defaultsKeys {
        static let myTeam = "myTeam"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TeamTextField.placeholder = "3309B"
        // Set Font for Main Menu Title and all future titles
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "BebasNeue", size: 34)!]
        self.title = "Welcome!"
        self.TeamTextField.delegate = self
        // Setup seasonPicker
        self.seasonPicker.delegate = self
        self.seasonPicker.dataSource = self
        self.seasonPicker.font = UIFont(name: "HelveticaNeue-Bold", size: 20)!
        self.seasonPicker.highlightedFont = UIFont(name: "HelveticaNeue-Bold", size: 20 )!
        self.seasonPicker.interitemSpacing = 20.0
        self.seasonPicker.viewDepth = 1000.0
        self.seasonPicker.pickerViewStyle = .Wheel
        self.seasonPicker.maskDisabled = false
        self.seasonPicker.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize.height = 900
        self.scrollView.contentSize.width = self.view.frame.width
    }
    // Changes function of text field and button
    @IBAction func editButton(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let stringOne = defaults.valueForKey(defaultsKeys.myTeam) as? String {
            self.TeamTextField.text = stringOne
        }

        self.visitProfileButton.setTitle("SAVE CHANGES", forState: .Normal)
        self.TeamTextField.backgroundColor = UIColor.redColor()
    }
    
    // Button next to teamfield that advances the user to the team they typed in or if editing myTeam, it will save the ccchanges
    @IBAction func visitProfileButton(sender: AnyObject) {
        if self.visitProfileButton.titleLabel!.text == "SAVE CHANGES" {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(self.TeamTextField.text, forKey: defaultsKeys.myTeam)
            defaults.synchronize()
            self.visitProfileButton.setTitle("VISIT PROFILE", forState: .Normal)
            self.TeamTextField.backgroundColor = UIColor.whiteColor()
            self.TeamTextField.text = ""
        }else {
            self.moveToTeamProfile(self.TeamTextField.text)
        }
    }
    
    // End editing if user taps off textfield
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // Button for myTeam
    @IBAction func myTeamButton(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let stringOne = defaults.valueForKey(defaultsKeys.myTeam) as? String {
            if stringOne.isEmpty {
                let alertController = UIAlertController(title: "You haven't told us what team you are on!", message:
                    "To configure 'My Team', press the wrench and type your team into the text box!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Will Do!", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                    
                })

            }else {
                self.moveToTeamProfile(stringOne)
            }
        }

        
    }
    
    // Give it a team, it moves to their profile
    func moveToTeamProfile(team: String!) {
        var team1 = team
        if team.isEmpty {
            team1 = "3309B"
        }
           // var homeButton: UIBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: "goHome")
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! UITabBarController
            //vc.navigationItem.rightBarButtonItem = homeButton
            // Destintation ViewController, set team
            let dest: OverviewTeamProfileViewController = vc.viewControllers?.first as! OverviewTeamProfileViewController
            var team2: Team! = Team()
            team2.num = team1.uppercaseString
            team2.season = self.season as String
            dest.team = team2
            // Set the title of the menuViewController
            vc.title = "Team \(team1)"
            // Present Profile
            self.showViewController(vc as UIViewController, sender: vc)
        
    }
    
    // Skills button, takes you to skills view and sends season along with it
    @IBAction func skills(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("skills") as! UITabBarController
        vc.title = "Skills"
        // Destintation ViewController, set season
        let dest: SkillsViewController = vc.viewControllers?.first as! SkillsViewController
         dest.title = "Robot Skills"
        (vc.viewControllers?.last as! ProgrammingSkillsViewController).title = "Programming Skills"
        (vc.viewControllers?.last as! ProgrammingSkillsViewController).season = self.season as String
        dest.season = self.season as String
        // Set the title of the menuViewController
       
        // Present Main Menu
        self.showViewController(vc as UIViewController, sender: vc)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if self.visitProfileButton.titleLabel!.text == "SAVE CHANGES" {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(self.TeamTextField.text, forKey: defaultsKeys.myTeam)
            defaults.synchronize()
            self.visitProfileButton.setTitle("VISIT PROFILE", forState: .Normal)
            self.TeamTextField.backgroundColor = UIColor.whiteColor()
            self.TeamTextField.text = ""
        }else {
            self.moveToTeamProfile(self.TeamTextField.text)
        }
        return true
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return seasons.count;
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        return seasons[item]
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        self.season = seasons[item]
    }
}
