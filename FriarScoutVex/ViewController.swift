//
//  ViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/6/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set the title to BebasNeue
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "BebasNeue", size: 34)!]
        
        //set the delegates
        self.usernameTextField.delegate = self;
        self.passwordTextField.delegate = self;
        
        //set password field to password characters
        self.passwordTextField.secureTextEntry = true;
    }
    
    //when the user taps whitespace, close all keyboards
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    @IBAction func loginButton(sender: UIButton) {
        
        var ref = Firebase(url:"https://docs-examples.firebaseio.com/")

    }
    
    //when the user hits the return key, close all keyboards
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        self.view.endEditing(true)
        return false
    }


}

