//
//  CircleView.swift
//  FriarScoutVex
//
//  Created by Matthew Krager on 8/10/15.
//  Copyright (c) 2015 Matthew Krager. All rights reserved.
//

import UIKit

class CircleView: UIView {
    let circleLayer: CAShapeLayer  = CAShapeLayer()
    var label: UILabel = UILabel()
    
    func setText(str:String) {
        self.label.text = str
        layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
       
        label.sizeToFit()
        label.center = self.convertPoint(self.center, fromView: self.superview)
        self.addSubview(label)
    }
    init(frame: CGRect, innerColor: CGColor = Colors.colorWithHexString("#858585").CGColor, rimColor: CGColor = UIColor.blueColor().CGColor, text:String = "", font:UIFont = UIFont(name: "HelveticaNeue-UltraLight", size: 30)!, fontColor:UIColor = UIColor.whiteColor() ) {
        super.init(frame: frame)
        label.text = text
        label.font = font
        label.textColor = fontColor
        label.sizeToFit()
        label.center = self.convertPoint(self.center, fromView: self.superview)

        self.backgroundColor = UIColor.clearColor()
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 10)/2, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        
        // Setup the CAShapeLayer
        circleLayer.path = circlePath.CGPath
        circleLayer.fillColor = innerColor
        circleLayer.strokeColor = rimColor
        circleLayer.lineWidth = 5.0
        
        // Don't draw the circle at start
        circleLayer.strokeEnd = 1.0
        layer.addSublayer(circleLayer)
    }
    
    func animateCircle(duration: NSTimeInterval) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.duration = duration
        
        animation.fromValue = 0
        animation.toValue = 1
        
        // Do a linear animation 
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        circleLayer.strokeEnd = 1.0
        
        // Do the actual animation
        circleLayer.addAnimation(animation, forKey: "animateCircle")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
