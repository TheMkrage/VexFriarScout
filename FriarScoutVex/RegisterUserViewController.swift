//
//  RegisterUserViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/6/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit


class RegisterUserViewController: UIViewController {
    @IBOutlet var scrollView: UIScrollView!
    //All the Text Fields
    @IBOutlet var firstNameTextField: UITextField!
    @IBOutlet var teamTextField: UITextField!
    @IBOutlet var eMailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var reEnterPasswordTextField: UITextField!
    @IBOutlet var lastNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        
        //set title
        self.title = "Register"
    }
    
    @IBAction func registerButton(sender: UIButton) {
        //make sure passwords match
        if(self.passwordTextField.text != self.reEnterPasswordTextField.text) {
            println("NOPE")
            return
        }
        
        let ref = Firebase(url: "https://vexscoutaccounts.firebaseio.com/")
        ref.createUser(self.eMailTextField.text, password: self.passwordTextField.text, withCompletionBlock: { (error: NSError!) -> Void in
            if error != nil {
                println(error.description)
                // Something went wrong. :(
            } else {
                // Create a new user dictionary accessing the user's info
                // provided by the authData parameter
                let newUser = [
                    "first name" : self.firstNameTextField.text,
                    "last name" : self.lastNameTextField.text,
                    "team" :self.teamTextField.text,
                    "email": self.eMailTextField.text
                ]
                // Create a child path with a key set to the uid underneath the "users" node
                ref.childByAppendingPath("users")
                    .childByAppendingPath("\(self.firstNameTextField.text) \(self.lastNameTextField.text)").setValue(newUser)
            }

        });
        
        
    }
    

    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize.height = 1000;
        self.scrollView.contentSize.width = self.view.frame.size.width;

    }
}
