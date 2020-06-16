//
//  FindCorrespondingButtonText.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 26/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

extension ViewController {
    
    func findCorrespondingButtonText() {
        let threshold = Constants.Drawings.verticalThreshold
        buttons = nonLabelElements.filter({$0.type == .symbol})
        for (i, button) in buttons.enumerated() {
            let buttonBottomLeftCorner = CGPoint(x: button.elementBoundingBox.minX, y: button.elementBoundingBox.maxY)
            for (j, label) in labels.enumerated() {
                let labelTopLeftCorner = CGPoint(x: label.elementBoundingBox.minX, y: label.elementBoundingBox.minY)
                let distance = computeEuclidianDistanceSquared(a: labelTopLeftCorner, b: buttonBottomLeftCorner).squareRoot()
                if distance < threshold {
                    buttons[i].data = label.text
                    labels[j].labelType = .buttonDescriptor
                    buttonDescriptionExists = true
                    break // go to next button
                }
            }
        }
    }
}
