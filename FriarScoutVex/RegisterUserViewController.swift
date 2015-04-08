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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
                // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize.height = 1000;
        self.scrollView.contentSize.width = self.view.frame.size.width;

    }
}
