//
//  MainMenuTableCell.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 8/16/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class MainMenuTableCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var backView: UIView!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var nothingLabel: UILabel!
    func setUp() {
        self.backView.layer.masksToBounds = true
        self.backView.layer.cornerRadius = 20
        self.titleLabel.layer.cornerRadius = 20
        self.titleLabel.layer.masksToBounds = true
        self.layoutSubviews()
        
    }
}
