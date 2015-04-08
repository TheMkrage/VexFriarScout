//
//  RegisterUserViewController.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 4/6/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit


class RegisterUserViewController: UIViewController, AKPickerViewDataSource, AKPickerViewDelegate {
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var pickerView: AKPickerView!
    
    let titles = ["Tokyo", "Kanagawa", "Osaka", "Aichi", "Saitama", "Chiba", "Hyogo", "Hokkaido", "Fukuoka", "Shizuoka"]
    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false;
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.pickerView.font = UIFont(name: "BebasNeue", size: 20)!
        self.pickerView.highlightedFont = UIFont(name: "BebasNeue", size: 20)!
        self.pickerView.interitemSpacing = 20.0
        self.pickerView.pickerViewStyle = .Flat
        self.pickerView.reloadData()

    }

    override func viewDidLayoutSubviews() {
        self.scrollView.contentSize.height = 1000;
        self.scrollView.contentSize.width = self.view.frame.size.width;

    }
    
   
    
    // MARK: - AKPickerViewDataSource
    
    func numberOfItemsInPickerView(pickerView: AKPickerView) -> Int {
        return self.titles.count
    }
    
    /*
    Image Support
    -------------
    Please comment '-pickerView:titleForItem:' entirely and
    uncomment '-pickerView:imageForItem:' to see how it works.
    */
    func pickerView(pickerView: AKPickerView, titleForItem item: Int) -> NSString {
        return self.titles[item]
    }
}
