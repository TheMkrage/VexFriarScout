//
//  UISettingsViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 8/28/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class UISettingsViewController: UIViewController, UITextFieldDelegate {
    struct defaultsKeys {
        static let myTeam = "myTeam"
    }
    
    @IBOutlet var myTeamTextField: UITextField!
    override func viewDidLoad() {
        self.myTeamTextField.delegate = self
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        var query = PFQuery(className: "Teams")
        query.whereKey("num", equalTo: self.myTeamTextField.text.uppercaseString)
        if let x = query.findObjects() as? [PFObject] {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(self.myTeamTextField.text.uppercaseString, forKey: defaultsKeys.myTeam)
            defaults.synchronize()
        }else {
            // Alert the user that what they typed doesn't exist
            let alertController = UIAlertController(title: "Oh no! ", message:
                "That team doesn't exist!", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Oops!", style: UIAlertActionStyle.Default,handler: nil))
        }
        return true
    }
}