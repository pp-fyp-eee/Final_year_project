//
//  ShowSuggestions.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 28/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

extension ViewController {
    
    @objc func WandButtonDidTap() {
        magicWandButton.isEnabled = false
        magicWandButton.layer.shadowOpacity = 0 // remove shadow
        magicWandLabel.isEnabled = false
        magicWandLabel.alpha = 0.5
        
        // determine which suggestions should be shown
        populateSuggestionsArray()
        
        // present button suggestions first
        suggestions = suggestions.reversed()
        
        // generate and show popups
        if !suggestions.isEmpty {
            presentPopOverWithSuggestedElement(0)
        }
        else {
            // no suggestions to show
            didShowSuggestions = true
        }
    }
    
    func populateSuggestionsArray() {
        var bodyLabelBeforeSubtitle: LabelInfo?
        var previousElementIsBody: Bool = false
        
        for element in finalElementPositions {
            if (element as? DrawingInfo)?.type == .symbol {
                previousElementIsBody = false
                if !buttonDescriptionExists {
                    guard let button = element as? DrawingInfo
                        else {break}
                    populateWithButtonDescription(given: button)
                }
            }
                
            else if (element as? LabelInfo)?.labelType == .body {
                previousElementIsBody = true
                bodyLabelBeforeSubtitle = element as? LabelInfo
            }
            
            else if (element as? LabelInfo)?.labelType == .imageBannerViewLabel {
                previousElementIsBody = false
                
            }
                
            else if (element as? LabelInfo)?.labelType == .subtitle {
                guard let subtitle = element as? LabelInfo
                    else {break}
                if previousElementIsBody {
                    populateWithDivider(bodyLabelBeforeSubtitle, subtitle)
                }
                previousElementIsBody = false
                bodyLabelBeforeSubtitle = nil
            }
                
            else {
                previousElementIsBody = false
            }
        }
    }
    
    func populateWithButtonDescription(given button: DrawingInfo) {
        let labelPosition: CGRect = CGRect(x: button.elementBoundingBox.minX - 15, y: button.elementBoundingBox.maxY + 4, width: 69, height: 18)
        let label: UILabel = UILabel(frame: labelPosition)
        
        guard let symbolClass = (button.data as? SymbolType)
            else {
                return
        }
        
        switch symbolClass {
        case .magnifying_glass:
            label.text = "Zoom"
            break
        case .profile:
            label.text = "Profile"
            break
        case .location:
            label.text = "Location"
            break
        }
        
        label.textAlignment = .center
        label.textColor = UIColor.link
        
        let description: SuggestionDescription = SuggestionDescription(title: "Add a \(label.text?.lowercased() ?? "") label", message: "Including a label that describes the functionality of a button can help users better understand its purpose.")
        let suggestion: SuggestedElements = SuggestedElements(suggestedView: label, description: description)
        suggestions.append(suggestion)
    }
    
    func populateWithDivider(_ bodyLabel: LabelInfo?, _ subtitle: LabelInfo) {
        guard let bodyLabel = bodyLabel
            else {return}
        
        let midY: CGFloat = (bodyLabel.elementBoundingBox.maxY + subtitle.elementBoundingBox.minY) / 2
        let separatorViewFrame: CGRect = CGRect(x: subtitle.elementBoundingBox.minX, y: midY, width: 371, height: 1)
        let separatorView: UIView = UIView(frame: separatorViewFrame)
        separatorView.backgroundColor = UIColor.separator
        
        let description: SuggestionDescription = SuggestionDescription(title: "Add a divider", message: "Inserting a divider between separate sections offers a visible boundary between adjacent elements.")
        let suggestion: SuggestedElements = SuggestedElements(suggestedView: separatorView, description: description)
        suggestions.append(suggestion)
    }
    
    func presentPopOverWithSuggestedElement(_ suggestionsIndex: Int) {
        if suggestionsIndex > suggestions.count - 1 {
            // MARK: continue code here
            didShowSuggestions = true
            setupOpenOnMacButton()
            setupShareSheetGeneratedUI()
            return
        }
        
        let currentSuggestion = suggestions[suggestionsIndex]
        
        let boundaryView = getBoundaryView(frame: currentSuggestion.suggestedView.frame)
        generatedBackgroundView.addSubview(boundaryView)
        
        let suggestedView = currentSuggestion.suggestedView
        generatedBackgroundView.addSubview(suggestedView)
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        let defaultAction = UIAlertAction(title: "Include", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  keep suggestedView, remove boundaryView
            boundaryView.removeFromSuperview()
            self.presentPopOverWithSuggestedElement(suggestionsIndex + 1)
            return
        })
        
        let deleteAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
            //  remove both suggestedView and boundaryView
            suggestedView.removeFromSuperview()
            boundaryView.removeFromSuperview()
            self.presentPopOverWithSuggestedElement(suggestionsIndex + 1)
            return
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            //  remove both suggestedView and boundaryView
            suggestedView.removeFromSuperview()
            boundaryView.removeFromSuperview()
            self.presentPopOverWithSuggestedElement(suggestionsIndex + 1)
            return
        })
        
        let title = NSMutableAttributedString(string: currentSuggestion.description.title)
        
        let titleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 21, weight: .heavy)] as [NSAttributedString.Key : Any]
        title.addAttributes(titleAttributes, range: NSMakeRange(0, NSString(string: title.string).length))
        
        alertController.setValue(title, forKey: "attributedTitle")
        
        let message = NSMutableAttributedString(string: currentSuggestion.description.message)
        let messageAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium)] as [NSAttributedString.Key : Any]
        
        message.addAttributes(messageAttributes, range: NSMakeRange(0, NSString(string: message.string).length))
        alertController.setValue(message, forKey: "attributedMessage")
        
        alertController.addAction(defaultAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = generatedBackgroundView
            
            // position of popover
            // + 5 for position of green box
            var popupRect = boundaryView.frame
            popupRect.size.width = 0
            popupRect.size.height = 0
            
            // for arrowHead - don't want to cover up the generated UI - want to minimise the cover, hence keep popover on sides
            print(currentSuggestion.suggestedView.frame.minX)
            if currentSuggestion.suggestedView.frame.minX < 431/2 {
                popoverController.permittedArrowDirections = [.right]
                popupRect.origin.x = boundaryView.frame.minX - 2
            }
            else {
                popoverController.permittedArrowDirections = [.left]
                popupRect.origin.x = boundaryView.frame.maxX + 2
            }
            
            popupRect.origin.y = boundaryView.frame.midY
            popoverController.sourceRect = popupRect
            popoverController.backgroundColor = .white
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func getBoundaryView(frame: CGRect) -> RectangularDashedView{
        var boundaryFrame: CGRect = frame
        boundaryFrame.origin.y -= 2
        boundaryFrame.size.height += 4
        
        let boundaryView = RectangularDashedView(frame: boundaryFrame)
        boundaryView.dashWidth = 1.5
        boundaryView.dashColor = UIColor.boundaryGreenColor
        boundaryView.dashLength = 3
        boundaryView.betweenDashesSpace = 2
        boundaryView.backgroundColor = .clear
        return boundaryView
    }
}
