//
//  UISettingsViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 8/28/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit
import Parse

class UISettingsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    var curSeason: String = ""
    var seasons:[String] = ["NBN", "Skyrise", "Toss Up", "Sack Attack"]
    struct defaultsKeys {
        static let myTeam = "myTeam"
    }
    
    @IBOutlet var myTeamTextField: UITextField!
    @IBOutlet var saveMyTeamButton: UIButton!
    @IBOutlet var currentSeasonLabel: UILabel!
    @IBOutlet var seasonPicker: UIPickerView!
    
    override func viewDidLoad() {
        self.seasonPicker.dataSource = self
        self.seasonPicker.delegate = self
        self.currentSeasonLabel.text = "Current Season: \(self.curSeason)"
        self.myTeamTextField.delegate = self
        // Team Information
        let defaults = NSUserDefaults.standardUserDefaults()
        var count = 0
        for str in seasons{
            if self.curSeason == str {
                self.seasonPicker.selectRow(count, inComponent: 0, animated: true)
            }
            count++
        }
        if let stringOne = defaults.valueForKey(defaultsKeys.myTeam) as? String {
            self.myTeamTextField.text = stringOne
        }
    }
    
    func saveMyTeamChanges() {
        var query = PFQuery(className: "Teams")
        query.whereKey("num", equalTo: self.myTeamTextField.text.uppercaseString)
        if let x = query.findObjects() as? [PFObject]{
            if !x.isEmpty {
                
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setValue(self.myTeamTextField.text.uppercaseString, forKey: defaultsKeys.myTeam)
                defaults.synchronize()
                self.saveMyTeamButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
                self.saveMyTeamButton.setTitle("Saved", forState: UIControlState.Normal)
            }else {
                // Alert the user that what they typed doesn't exist
                let alertController = UIAlertController(title: "Oh no! ", message:
                    "That team doesn't exist!", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Oops!", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion:  { () -> Void in
                    self.myTeamTextField.text = ""
                })
            }
        }

    }
    
    @IBAction func pressedMyTeamSaveButton(sender: AnyObject) {
        if self.saveMyTeamButton.titleLabel!.text != "Saved" {
            self.saveMyTeamChanges()
        }
    }
    
    // End editing if user taps off textfield
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.saveMyTeamChanges()
        self.view.endEditing(true)
    }
    
    // Text Field Delegate
    func textFieldDidBeginEditing(textField: UITextField) {
        self.saveMyTeamButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.saveMyTeamButton.setTitle("Save Changes", forState: UIControlState.Normal)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.saveMyTeamChanges()
        self.view.endEditing(true)
        return true
    }
    
    // UIPicker Delegate and Datasource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return seasons[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.curSeason = seasons[row]
        self.currentSeasonLabel.text = "Current Season: \(self.curSeason)"
        (self.navigationController?.viewControllers[0] as! MainMenuViewControllerWithSearch).curSeason = self.curSeason
    }
}