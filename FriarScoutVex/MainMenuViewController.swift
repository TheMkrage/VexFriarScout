//
//  MainMenuViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/8/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController, UITextFieldDelegate, AKPickerViewDataSource, AKPickerViewDelegate {
    var userProfile: UserProfile = UserProfile()
    var season: NSString = "Skyrise"
    let seasons = ["Skyrise", "NBN"]
    @IBOutlet var seasonPicker: AKPickerView!
    @IBOutlet var TeamTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.TeamTextField.delegate = self
        self.seasonPicker.delegate = self
        self.seasonPicker.dataSource = self
        
        self.seasonPicker.font = UIFont(name: "HelveticaNeue-Light", size: 20)!
        self.seasonPicker.highlightedFont = UIFont(name: "HelveticaNeue", size: 20)!
        self.seasonPicker.interitemSpacing = 20.0
        self.seasonPicker.viewDepth = 1000.0
        self.seasonPicker.pickerViewStyle = .Wheel
        self.seasonPicker.maskDisabled = false
        //self.seasonPicker.reloadData()
    }
    @IBAction func visitProfileButton(sender: AnyObject) {
        self.moveToTeamProfile(self.TeamTextField.text)
    }
    
    // End editing if user taps off textfield
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    @IBAction func myTeamButton(sender: AnyObject) {
       self.moveToTeamProfile(self.userProfile.team)
    }
    func moveToTeamProfile(team: String!) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! UITabBarController
        // Destintation ViewController, set team
        let dest: OverviewTeamProfileViewController = vc.viewControllers?.first as! OverviewTeamProfileViewController
        var team2: Team! = Team()
        team2.num = team
        
        dest.team = team2
        // Set the title of the menuViewController
        vc.title = "Team \(team)"
        // Present Profile
        self.showViewController(vc as UIViewController, sender: vc)
        /*
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! TeamProfileViewController
        var team: Team! = Team()
        team.num = self.TeamTextField.text
        vc.team = team
        // Set the title of the menuViewController
        vc.title = "Team \(self.TeamTextField.text)"
        // Present Main Menu
        self.showViewController(vc as UIViewController, sender: vc)*/
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        moveToTeamProfile(textField.text)
        return true
    }
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        println("count!")
        return seasons.count;
    }
    
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> String {
        println("GETTING INFO")
        return seasons[item]
    }
    
    func pickerView(pickerView: AKPickerView, didSelectItem item: Int) {
        self.season = seasons[item]
    }
}
