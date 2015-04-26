//
//  ViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/6/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

// Login screen viewcontroller
class LogInViewController: UIViewController, UITextFieldDelegate {
    
    // TextFields and Label used to display errors
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    // Check Box used to remember login info
    @IBOutlet var rememberMeCheckBox: UICheckBoxButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the title to BebasNeue (it is now set for good)
         self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "BebasNeue", size: 34)!]
        // Set the delegates
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        // Email keyboard
        self.usernameTextField.keyboardType = UIKeyboardType.EmailAddress
        // Set password field to password characters
        self.passwordTextField.secureTextEntry = true
        // Return -> Done or Next
        self.usernameTextField.returnKeyType = UIReturnKeyType.Next
        self.passwordTextField.returnKeyType = UIReturnKeyType.Done
        // Check For RememberMe
        retrieveRememberMeValues()
    }
    
    func retrieveRememberMeValues() {
        // If there is a valid string value in username (this assumes password is the same) then set those string to the fields
        /*if (NSUserDefaults.valueForKey("username") != nil) {
            self.usernameTextField.text = NSUserDefaults.valueForKey("username") as! String
            self.passwordTextField.text = NSUserDefaults.valueForKey("password") as! String
           self.rememberMeCheckBox.setTicked()
        }*/
    }
    
    // When the user taps whitespace, close all keyboards
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)

    }
    
    @IBAction func loginButton(sender: UIButton) {
        self.login()
    } // End of func loginButton
    
    func login() {
        // Connect and auth
        var ref = Firebase(url:"https://vexscoutaccounts.firebaseio.com/")
        ref.authUser(self.usernameTextField.text, password: self.passwordTextField.text) { (error:NSError!, authData:FAuthData!) -> Void in
            // if any textfields are blank
            if(self.usernameTextField.text.isEmpty || self.passwordTextField.text.isEmpty) {
                self.errorLabel.text = "A FIELD WAS LEFT BLANK!"
                self.errorLabel.hidden = false;
                return
            }
            // If there is an error
            if error != nil {
                if let errorCode = FAuthenticationError(rawValue: error.code) {
                    switch (errorCode) {
                    case .InvalidEmail:
                        self.errorLabel.text = "INVALID EMAIL!"
                        self.errorLabel.hidden = false
                    case .InvalidPassword:
                        self.errorLabel.text = "INVALID PASSOWRD!"
                        self.errorLabel.hidden = false
                    default:
                        self.errorLabel.text = "UNKNOWN ERROR!"
                        self.errorLabel.hidden = false
                    }
                }
                // if everything goes smooth
            }else {
                // Create new VC
                var vc  = self.storyboard?.instantiateViewControllerWithIdentifier("MainMenu") as! MainMenuViewController
                // Connect and get first name of accounts being used, set title of Main Menu
                ref.childByAppendingPath("users").childByAppendingPath(authData.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    let name = snapshot.value["first name"] as! NSString
                    vc.title = "Hello \(name)"
                })
                // Present
                println(vc)
                self.showViewController(vc as UIViewController, sender: vc)
            }
        } // End of auth
    }// End of login
    
    // Check if Remember Me is checked and save/delete values accordingly. Then, end all editing and clear fields when view is left
    override func viewWillDisappear(animated: Bool) {
        // If CheckBox isChecked, save values for username and password, if not save blank strings
        if self.rememberMeCheckBox.isChecked {
            NSUserDefaults.setValue(self.usernameTextField.text, forKey: "username")
            NSUserDefaults.setValue(self.passwordTextField.text, forKey: "password")
            // Figure out how to synchronize plz and how to make warnings
        }else {
            NSUserDefaults.setValue("", forKey: "username")
            NSUserDefaults.setValue("", forKey: "password")
        }
        self.view.endEditing(true)
        self.clearAllFields()
    }
    
    func clearAllFields () {
        self.usernameTextField.text = nil
        self.passwordTextField.text = nil
    }
    
    // When the user hits the return key, close all keyboards by default
    // if username field, move to password
    // if password, click the login button
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isEqual(self.usernameTextField) {
            self.passwordTextField.becomeFirstResponder()
        }else if textField.isEqual(self.passwordTextField) {
            self.login()
        }else {
            self.view.endEditing(true)
        }
        return false
    }
}

