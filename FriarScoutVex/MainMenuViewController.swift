//
//  MainMenuViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/8/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit


class MainMenuViewController: UIViewController, UITextFieldDelegate {
    var userProfile: UserProfile = UserProfile()
    @IBOutlet var TeamTextField: UITextField!
    
    override func viewDidLoad() {
        self.TeamTextField.delegate = self;
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
}
