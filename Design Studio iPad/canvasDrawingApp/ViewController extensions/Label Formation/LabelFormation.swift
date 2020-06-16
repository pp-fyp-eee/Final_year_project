//
//  LabelFormation.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 23/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

extension ViewController {
    
    func populateNonLabelElements() {
        nonLabelElements = drawingInfo.filter({$0.type != .letter})
    }
    
    func populateLabels() {
        var handwrittenLetters: [DrawingInfo] = drawingInfo.filter({$0.type == .letter})
        handwrittenLetters.sort {abs($0.elementBoundingBox.minY - $1.elementBoundingBox.minY) > Constants.LabelFormation.verticalThreshold ? $0.elementBoundingBox.minY < $1.elementBoundingBox.minY : $0.elementBoundingBox.minX < $1.elementBoundingBox.minX}
        
        print("-----")
        print("Sorted letters by position with threshold:")
        print(handwrittenLetters)
        
        // define currentLabel, initialised to default CGRect
        var currentLabel: LabelInfo = LabelInfo(elementBoundingBox: CGRect())
        
        // update currentLabel to first element of handwrittenLetters array (if not empty)
        if !handwrittenLetters.isEmpty {
            currentLabel.text = handwrittenLetters[0].data as! String
            currentLabel.elementBoundingBox = handwrittenLetters[0].elementBoundingBox
        }
        
        // loop through the handwrittenLetters array
        var i = 0
        
        while i < handwrittenLetters.count - 1 {
            if isSameLabel(firstLetter: handwrittenLetters[i], secondLetter: handwrittenLetters[i+1]) {
                currentLabel.text += handwrittenLetters[i+1].data as! String
                currentLabel.elementBoundingBox = getUpdatedBoundingBox(handwrittenLetters[i+1].elementBoundingBox, currentLabel.elementBoundingBox)
            }
            else {
                labels.append(currentLabel)
                // reset
                currentLabel = LabelInfo(elementBoundingBox: CGRect())
                currentLabel.text = handwrittenLetters[i+1].data as! String
                currentLabel.elementBoundingBox = handwrittenLetters[i+1].elementBoundingBox
            }
            i += 1
        }
        
        // for final label
        labels.append(currentLabel)
    }
    
    private func isSameLabel(firstLetter: DrawingInfo, secondLetter: DrawingInfo) -> Bool {
        let firstElementCorner = CGPoint(x: firstLetter.elementBoundingBox.maxX, y: firstLetter.elementBoundingBox.minY)
        let secondElementCorner = CGPoint(x: secondLetter.elementBoundingBox.minX, y: secondLetter.elementBoundingBox.minY)
        
        let (xDistance, yDistance) = manhattanNorm(a: firstElementCorner, b: secondElementCorner)
        if xDistance > Constants.LabelFormation.horizontalThreshold || yDistance > Constants.LabelFormation.verticalThreshold {
            return false
        }
        return true
    }
    
    private func manhattanNorm(a: CGPoint, b: CGPoint) -> (CGFloat, CGFloat) {
        let absoluteHorizontalDistance = abs(a.x - b.x)
        let absoluteVerticalDistance = abs(a.y - b.y)
        return (absoluteHorizontalDistance, absoluteVerticalDistance)
    }
    
    private func getUpdatedBoundingBox(_ secondLetterBoundingBox: CGRect, _ currentLabelBoundingBox: CGRect) -> CGRect {
        var updatedBoundingBox: CGRect = currentLabelBoundingBox
        if secondLetterBoundingBox.minX < currentLabelBoundingBox.minX {
            // new letter is underneath previous one
            updatedBoundingBox.origin.x = secondLetterBoundingBox.origin.x
            updatedBoundingBox.size.height += secondLetterBoundingBox.size.height
        }
        else if secondLetterBoundingBox.maxX > currentLabelBoundingBox.maxX {
            // new letter is beside previous one
            updatedBoundingBox.size.width += secondLetterBoundingBox.size.width
        }
        return updatedBoundingBox
    }
}
