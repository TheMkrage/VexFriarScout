//
//  MainMenuViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/8/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit


class MainMenuViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var TeamTextField: UITextField!
    
    override func viewDidLoad() {
        self.TeamTextField.delegate = self;
    }
    @IBAction func visitProfileButton(sender: AnyObject) {
        self.moveToTeamProfile(self.TeamTextField.text)
    }
    
    func moveToTeamProfile(team: String!) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TeamProfile") as! TeamProfileViewController
        vc.team = self.TeamTextField.text
        // Set the title of the menuViewController
        vc.title = "Team \(self.TeamTextField.text)"
        // Present Main Menu
        self.showViewController(vc as UIViewController, sender: vc)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        moveToTeamProfile(textField.text)
        return true
    }
}
