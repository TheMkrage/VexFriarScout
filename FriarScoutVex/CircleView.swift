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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        // Use UIBezierPath as an easy way to create the CGPath for the layer.
        // The path should be the entire circle.
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 10)/2, startAngle: 0.0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        
        // Setup the CAShapeLayer with the path, colors, and line width
        circleLayer.path = circlePath.CGPath
        circleLayer.fillColor = Colors.colorWithHexString("#858585").CGColor
        circleLayer.strokeColor = UIColor.blueColor().CGColor
        circleLayer.lineWidth = 5.0
        
        // Don't draw the circle initially
        circleLayer.strokeEnd = 1.0
        
        
        // 1
        let textLayer = CATextLayer()
        textLayer.frame = CGRectMake(frame.width/2, frame.height/2, 0, 0)
        //Draw Text
        textLayer.string = "Hello"
        
        // Add the circleLayer to the view's layer's sublayers
        layer.addSublayer(circleLayer)
    }
    
    func animateCircle(duration: NSTimeInterval) {
        // We want to animate the strokeEnd property of the circleLayer
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        // Set the animation duration appropriately
        animation.duration = duration
        
        // Animate from 0 (no circle) to 1 (full circle)
        animation.fromValue = 0
        animation.toValue = 1
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        
        // Set the circleLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        circleLayer.strokeEnd = 1.0
        
        // Do the actual animation
        circleLayer.addAnimation(animation, forKey: "animateCircle")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
