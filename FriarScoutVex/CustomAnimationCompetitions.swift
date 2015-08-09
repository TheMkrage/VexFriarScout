//
//  CustomAnimationCompetitions.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 8/5/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class CustomAnimationCompetitions: RAMItemAnimation {
    
    var counter = 0
    /*func animateChange() {
        if counter % 2 == 0 {
            icon.image = UIImage(named: "flames.png")
        }else {
            icon.image = UIImage(named: "rs.png")
        }
        
    }*/
    override func playAnimation(icon : UIImageView, textLabel : UILabel) {
        for i in 0...20 {
            if i % 2 == 0 {
                icon.image = UIImage(named: "flames.png")
            }else {
                icon.image = UIImage(named: "rs.png")
            }
            sleep(1)
        }
    }
    
    override func deselectAnimation(icon : UIImageView, textLabel : UILabel, defaultTextColor : UIColor) {
        
    }
    
    override func selectedState(icon: UIImageView, textLabel : UILabel) {
        if let imageIcon = icon.image {
            icon.tintColor = iconSelectedColor
        }
    }
}
