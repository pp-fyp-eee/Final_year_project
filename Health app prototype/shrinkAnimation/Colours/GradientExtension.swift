//
//  GradientExtension.swift
//  shrinkAnimation
//
//  Created by Pranav Paul on 10/03/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

extension UIView {
    
    func setGradientBackgroundColour(colourOne: UIColor, colourTwo: UIColor) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        gradientLayer.colors = [colourOne.cgColor, colourTwo.cgColor]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
