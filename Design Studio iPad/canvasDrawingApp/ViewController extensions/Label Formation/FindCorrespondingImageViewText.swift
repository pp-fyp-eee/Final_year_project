//
//  FindCorrespondingImageViewText.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 26/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

extension ViewController {
    
    func findCorrespondingImageViewText() {
        imageViews = nonLabelElements.filter({$0.type == .imageBannerView || $0.type == .imageCellView})
        
        var i = 0
        
        while i < imageViews.count {
            if imageViews[i].type == .imageCellView {
                imageViews[i].data = findCorrespondingLabelCellView(boundingBox: imageViews[i].elementBoundingBox)
            }
            else if imageViews[i].type == .imageBannerView {
                imageViews[i].data = findCorrespondingLabelBannerView(boundingBox: imageViews[i].elementBoundingBox)
            }
            
            i += 1
        }
        
        print(imageViews)
    }
    
    private func findCorrespondingLabelCellView(boundingBox: CGRect, type: LabelType = .body) -> String {
        let bottomLeftCornerCellView: CGPoint = CGPoint(x: boundingBox.minX, y: boundingBox.maxY)
        var correspondingText = ""
        var minimumSquareDistanceBelowCellView = pow(view.frame.height, 2)
        var correspondingIndex = 0
        for (i, label) in labels.enumerated() {
            let topLeftCornerLabel = CGPoint(x: label.elementBoundingBox.minX, y: label.elementBoundingBox.minY)
            let squareDistanceToCellView = computeEuclidianDistanceSquared(a: topLeftCornerLabel, b: bottomLeftCornerCellView)
            if squareDistanceToCellView < minimumSquareDistanceBelowCellView {
                correspondingText = label.text
                minimumSquareDistanceBelowCellView = squareDistanceToCellView
                correspondingIndex = i
            }
        }
        labels[correspondingIndex].labelType = type
        if type == .body {
            labels[correspondingIndex].formatting = Constants.TextFormatting.getBodyFormatting()
        } else if type == .imageBannerViewLabel {
            labels[correspondingIndex].formatting = Constants.TextFormatting.getImageBannerViewTextFormatting()
        }
        return correspondingText
    }
    
    func computeEuclidianDistanceSquared(a: CGPoint, b: CGPoint) -> CGFloat {
        return pow(a.x - b.x, 2) + pow(a.y - b.y, 2)
    }
    
    private func findCorrespondingLabelBannerView(boundingBox: CGRect) -> String {
        // check inside the banner view
        for (i, label) in labels.enumerated() {
            if boundingBox.contains(label.elementBoundingBox) {
                labels[i].labelType = .imageBannerViewLabel
                labels[i].formatting = Constants.TextFormatting.getImageBannerViewTextFormatting()
                return label.text
            }
        }
        
        // label is outside (check below)
        return findCorrespondingLabelCellView(boundingBox: boundingBox, type: .imageBannerViewLabel)
    }
}
