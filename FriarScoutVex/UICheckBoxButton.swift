//
//  UICheckBoxButton.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/26/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class UICheckBoxButton: UIButton {
    // Two hexadecimal values used for a blank square (unticked) and a checked square (ticked)
    let tickedString: String! = "u2611"
    let untickedString: String! = "u2610"
    // Bool to return if the checkbox should be checked or not
    var isChecked: Bool = false
    
    
    func setTicked() {
        isChecked = true
        update()
    }
    
    func setUnticked() {
        isChecked = false
        update()
    }
    
    func toggle() {
        isChecked = !isChecked
        update()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        toggle()
    }
    // Sets isChecked to the visual checkbox
    func update() {
        if isChecked {
            self.setTitle(tickedString, forState: UIControlState.Normal)
        }else {
            self.setTitle(untickedString, forState: UIControlState.Normal)
        }
    }
}
