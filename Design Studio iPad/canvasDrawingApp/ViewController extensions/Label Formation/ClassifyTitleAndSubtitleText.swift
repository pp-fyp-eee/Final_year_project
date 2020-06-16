//
//  ClassifyTitleAndSubtitleText.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 26/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

extension ViewController {
    
    func classifyTitleAndSubtitleLabels() {
        for (i, label) in labels.enumerated() {
            if label.labelType == nil {
                // not been associated with a UI element yet
                labels[i].labelType = .subtitle
                labels[i].formatting = Constants.TextFormatting.getSubTitleFormatting()
                if label.elementBoundingBox.minY < Constants.Drawings.titleDistanceThreshold {
                    labels[i].labelType = .title
                    labels[i].formatting = Constants.TextFormatting.getTitleFormatting()
                }
            }
        }
    }
}
