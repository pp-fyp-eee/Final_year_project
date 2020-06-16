//
//  ElementPositions.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 26/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

struct ElementPositions {
    
    static let titlePosition: CGRect = CGRect(x: 30, y: 28, width: 300, height: 77)
    
    static let imageBannerViewTopSpacing: CGFloat = 3
    static let imageBannerViewBottomSpacing: CGFloat = 23
    static let imageBanerViewWidth: CGFloat = 428 // not the entire iPad device width - should just be the width of the iPhone
    static func getImageBannerViewHeight(drawnHeight: CGFloat) -> CGFloat {
        // round to nearest 243 pts
        let roundedValue: Int = 243 * Int(round(drawnHeight/243))
        return CGFloat(roundedValue)
    }
    
    static func getImageBannerViewLabelPosition(imageBannerViewHeight: CGFloat) -> CGRect {
        let position: CGRect = CGRect(x: titlePosition.minX, y: imageBannerViewHeight + 33, width: 300, height: 74)
        return position
    }
    
    static let imageCellViewWidth: CGFloat = 140
    static let imageCellViewHeight: CGFloat = 140
    
}

enum UIElementType {
    case tableViewCell
    case imageBannerView
    case imageCellView
    case symbol
    case switchButton
    case title
    case subtitle
    case body
    case imageBannerViewLabel
}

extension ViewController {
 
    func getFinalElementPositions() {
        finalElementPositions = labels
        finalElementPositions.append(contentsOf: imageViews)
        
        finalElementPositions.sort {abs($0.elementBoundingBox.minY - $1.elementBoundingBox.minY) > Constants.LabelFormation.verticalThreshold ? $0.elementBoundingBox.minY < $1.elementBoundingBox.minY : $0.elementBoundingBox.minX < $1.elementBoundingBox.minX}
         
        var previousBoundingBox: CGRect = CGRect()
        var previousElementType: UIElementType?
        
        // can only update CGRect
        // update the image views when creating the image views (creating UIImageView directly) - create array of uiviews :)
        for (i, element) in finalElementPositions.enumerated() {
            if (element as? LabelInfo)?.labelType == .title {
                finalElementPositions[i].elementBoundingBox = ElementPositions.titlePosition
                previousElementType = .title
            }
            else if (element as? DrawingInfo)?.type == .imageBannerView {
                finalElementPositions[i].elementBoundingBox = CGRect(x: 1, y: previousBoundingBox.maxY + ElementPositions.imageBannerViewTopSpacing, width: ElementPositions.imageBanerViewWidth, height: ElementPositions.getImageBannerViewHeight(drawnHeight: finalElementPositions[i].elementBoundingBox.height))
                previousElementType = .imageBannerView
            }
            else if (element as? LabelInfo)?.labelType == . imageBannerViewLabel {
                finalElementPositions[i].elementBoundingBox = ElementPositions.getImageBannerViewLabelPosition(imageBannerViewHeight: previousBoundingBox.height)
                previousElementType = .imageBannerViewLabel
            }
            else if (element as? LabelInfo)?.labelType == .subtitle {
                if previousElementType == .imageBannerViewLabel {
                    finalElementPositions[i].elementBoundingBox.origin.x = finalElementPositions[i].elementBoundingBox.origin.x < 431/2 ? ElementPositions.titlePosition.minX : 431/2 + ElementPositions.titlePosition.minX + 15.5
                    finalElementPositions[i].elementBoundingBox.origin.y = previousBoundingBox.maxY + ElementPositions.imageBannerViewBottomSpacing + 1 // should be 374
                    finalElementPositions[i].elementBoundingBox.size.width = max(250, finalElementPositions[i].elementBoundingBox.size.width)
                    finalElementPositions[i].elementBoundingBox.size.height = 33
                }
                else {
                    // below body label
                    finalElementPositions[i].elementBoundingBox.origin.x = finalElementPositions[i].elementBoundingBox.origin.x < 431/2 ? ElementPositions.titlePosition.minX : 431/2 + ElementPositions.titlePosition.minX + 15.5
                    finalElementPositions[i].elementBoundingBox.origin.y = previousBoundingBox.maxY + 33
                    finalElementPositions[i].elementBoundingBox.size.width = max(250, finalElementPositions[i].elementBoundingBox.size.width)
                    finalElementPositions[i].elementBoundingBox.size.height = 33
                }
                previousElementType = .subtitle
            }
             else if (element as? DrawingInfo)?.type == .imageCellView {
                finalElementPositions[i].elementBoundingBox.size.height = ElementPositions.imageCellViewHeight
                finalElementPositions[i].elementBoundingBox.size.width = ElementPositions.imageCellViewWidth
                // 431 is width of iPhone in view
                finalElementPositions[i].elementBoundingBox.origin.x = finalElementPositions[i].elementBoundingBox.origin.x < 431/2 ? ElementPositions.titlePosition.minX : 261
                if previousElementType == .subtitle {
                    finalElementPositions[i].elementBoundingBox.origin.y = previousBoundingBox.maxY + 15
                }
                else if previousElementType == .imageCellView {
                    finalElementPositions[i].elementBoundingBox.origin.y = previousBoundingBox.minY
                }
                previousElementType = .imageCellView
            }
            else if (element as? LabelInfo)?.labelType == .body {
                finalElementPositions[i].elementBoundingBox.size.height = 30
                finalElementPositions[i].elementBoundingBox.size.width = ElementPositions.imageCellViewWidth
                finalElementPositions[i].elementBoundingBox.origin.x = finalElementPositions[i].elementBoundingBox.origin.x < 431/4 ? ElementPositions.titlePosition.minX : 261
            
                if previousElementType == .imageCellView {
                    finalElementPositions[i].elementBoundingBox.origin.y = previousBoundingBox.maxY + 8
                }
                else if previousElementType == .body {
                    finalElementPositions[i].elementBoundingBox.origin.y = previousBoundingBox.minY
                }
                previousElementType = .body
            }
            // MARK: TODO fill in remaining types eg tableviewcells
            
            previousBoundingBox = finalElementPositions[i].elementBoundingBox
        }
        
        // append buttons last
        for (i, button) in buttons.enumerated() {
            if button.elementBoundingBox.minY < ElementPositions.titlePosition.maxY {
                let updatedXPosition: CGFloat = button.elementBoundingBox.minX > 431/2 ? 368 : 30
                buttons[i].elementBoundingBox = CGRect(x: updatedXPosition, y: 0, width: 40, height: 40)
            }
        }
        
        finalElementPositions.append(contentsOf: buttons)

        for element in finalElementPositions {
            print("---")
            print(element)
        }
    }

}
