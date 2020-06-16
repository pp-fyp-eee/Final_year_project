////
////  ShowCustomPopover.swift
////  canvasDrawingApp
////
////  Created by Pranav Paul on 04/06/2020.
////  Copyright © 2020 Pranav Paul. All rights reserved.
////

import UIKit

extension ViewController: UIPopoverPresentationControllerDelegate, PopoverDelegate {
    
    // analyse tap meta-data for the view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // return if suggestions view hasn't been shown yet
        if !didShowSuggestions {
            return
        }
        
        if let touch = touches.first {
            let currentPoint = touch.location(in: generatedBackgroundView)
            print(currentPoint)
            
            for element in generatedBackgroundView.subviews {
                if element.frame.contains(currentPoint) {
                    tappedView = element
                    break
                }
            }
            
            for element in finalElementPositions {
                if (element.elementBoundingBox.contains(currentPoint)) {
                    print(element)
                    
                    // any imageView
                    if (element as? DrawingInfo)?.type == .imageBannerView || (element as? DrawingInfo)?.type == .imageCellView {
                        guard let
                            element = element as? DrawingInfo else {break}
                        if (imageDictionaries.keys.contains(element.data as? String ?? "")) {
                            showImageViewPopOverController(with: element, tapLocation: currentPoint)
                        }
                    }
                    
                }
            }
        }
    }
    
    func showImageViewPopOverController(with drawnImageView: DrawingInfo, tapLocation: CGPoint) {
        tappedDrawing = drawnImageView
        let popoverContentController = self.storyboard?.instantiateViewController(withIdentifier: "PopoverCollectionContentController") as? PopoverImageCollectionContentController
        popoverContentController?.modalPresentationStyle = .popover
        popoverContentController?.preferredContentSize = CGSize(width: 250, height: 350)
        
        if let popoverPresentationController = popoverContentController?.popoverPresentationController {
            popoverPresentationController.sourceView = generatedBackgroundView
            popoverPresentationController.sourceRect = drawnImageView.elementBoundingBox
            
            if let popoverController = popoverContentController {
                popoverController.images = []
                for i in 0..<(imageDictionaries[drawnImageView.data as? String ?? ""]?.count ?? 0){
                    let image = imageDictionaries[drawnImageView.data as! String]![i].image
                    popoverController.images.append(image)
                }

                if tapLocation.x < generatedBackgroundView.frame.width/2 {
                    print("here")
                    popoverPresentationController.permittedArrowDirections = [.right]
                }
                else {
                    popoverPresentationController.permittedArrowDirections = [.left]
                }
                popoverController.delegate = self
               
                present(popoverController, animated: true, completion: nil)
                
            }
        }
    }
    
    // code that runs when the popover is dismissed
    func popoverDismissed() {
    
        // tapped an imageView
        if let tappedImageView = tappedView as? UIImageView {
            
            // selected image from photo library
            if didSelectImageFromLibrary {
                tappedImageView.image = selectedImage
                tappedImageView.isAccessibilityElement = false
                tappedImageView.clipsToBounds = true
                tappedImageView.contentMode = .scaleAspectFill
            }
          
            // selected downlaoded image from Unsplash API
            else {
                guard let data = tappedDrawing?.data as? String else {return}
                tappedImageView.image = imageDictionaries[data]?[selectedIndex].image
                tappedImageView.isAccessibilityElement = true
                tappedImageView.accessibilityLabel = imageDictionaries[data]?[selectedIndex].description
                
            }
            
            adjustFontLabelBannerView()
        }
    }
    
}
