//
//  InsertUIViews.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 27/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

enum ImageType {
    case Square
    case Landscape
}

struct ImageData {
    var image: UIImage
    var description: String
    var type: ImageType
    var position: CGRect
}

extension ViewController {
    
    func insertGeneratedViews() {
        
        setupGeneratedBackgroundView()
        
        // animate out the canvas view and top buttons
        UIView.animate(withDuration: 2.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.canvasView.alpha = 0
            self.generateButton.alpha = 0
            self.backToProjectsButton.alpha = 0
        }, completion: { (completed: Bool) in
            self.canvasView.removeFromSuperview()
            self.generateButton.removeFromSuperview()
            self.backToProjectsButton.removeFromSuperview()
        })
        
        // place elements on the generatedBackgroundView - will animate in later
        for element in finalElementPositions {
            
            if (element as? DrawingInfo)?.type == .imageBannerView {
                let imageView: UIImageView = UIImageView(frame: element.elementBoundingBox)
                if let imageName: String = (element as? DrawingInfo)?.data as? String {
                    getImageMetaData(imageName: imageName, type: .Landscape, imageView: imageView, animateIn: true, isImageBannerView: true)
                    imageView.alpha = 0
                    generatedImageViews.append(imageView)
                    generatedBackgroundView.addSubview(imageView)
                }
            }
                
            else if (element as? DrawingInfo)?.type == .imageCellView {
                let imageView: UIImageView = UIImageView(frame: element.elementBoundingBox)
                imageView.contentMode = .scaleAspectFill
                imageView.layer.cornerRadius = Constants.ViewCornerRadius.radius
                imageView.clipsToBounds = true
                if let imageName: String = (element as? DrawingInfo)?.data as? String {
                    getImageMetaData(imageName: imageName, type: .Square, imageView: imageView, animateIn: true)
                    imageView.alpha = 0
                    generatedImageViews.append(imageView)
                    generatedBackgroundView.addSubview(imageView)
                }
            }
                
            else if (element as? DrawingInfo)?.type == .symbol {
                let button = UIButton(type: .custom)
                button.frame = element.elementBoundingBox
                
                if let symbol = (element as? DrawingInfo)?.data as? SymbolType {
                    switch symbol {
                    case .magnifying_glass:
                        button.setImage(UIImage(named: "Magnifying_glass"), for: .normal)
                        break
                    case .profile:
                        button.setImage(UIImage(named: "Profile_icon"), for: .normal)
                        break
                    case .location:
                        button.setImage(UIImage(named: "Location"), for: .normal)
                        break
                    }
                }
                generatedBackgroundView.addSubview(button)
                generatedButtons.append(button)
                button.alpha = 0
                animateSubViewIn(subView: button)
            }
            
                
            else if (element as? LabelInfo)?.labelType == .title {
                let label: UILabel = UILabel(frame: element.elementBoundingBox)
                if let formatting = (element as? LabelInfo)?.formatting as [NSAttributedString.Key : Any]? {
                    let text: String = (element as? LabelInfo)?.text ?? "Title"
                    label.attributedText = NSAttributedString(string: text.firstUppercased, attributes: formatting)
                    generatedLabels.append(label)
                    generatedBackgroundView.addSubview(label)
                    // for animation
                    label.frame.size.width = 0
                    animateLabelIn(label: label, width: element.elementBoundingBox.width)
                }
            }
            
            else if (element as? LabelInfo)?.labelType == .subtitle {
                let label: UILabel = UILabel(frame: element.elementBoundingBox)
                if let formatting = (element as? LabelInfo)?.formatting as [NSAttributedString.Key : Any]? {
                    let text: String = (element as? LabelInfo)?.text ?? "Subtitle"
                    label.attributedText = NSAttributedString(string: text.firstUppercased, attributes: formatting)
                    generatedLabels.append(label)
                    generatedBackgroundView.addSubview(label)
                    // for animation
                    label.frame.size.width = 0
                    animateLabelIn(label: label, width: element.elementBoundingBox.width)
                }
            }
            
            else if (element as? LabelInfo)?.labelType == .imageBannerViewLabel {
                let label: UILabel = UILabel(frame: element.elementBoundingBox)
                if let formatting = (element as? LabelInfo)?.formatting as [NSAttributedString.Key : Any]? {
                    let text: String = (element as? LabelInfo)?.text ?? "Image label"
                    label.attributedText = NSAttributedString(string: text.firstUppercased, attributes: formatting)
                    generatedLabels.append(label)
                    generatedBackgroundView.addSubview(label)
                    // for animation
                    label.frame.size.width = 0
                    animateLabelIn(label: label, width: element.elementBoundingBox.width)
                }
                
            }
            
            else if (element as? LabelInfo)?.labelType == .body {
                let label: UILabel = UILabel(frame: element.elementBoundingBox)
                if let formatting = (element as? LabelInfo)?.formatting as [NSAttributedString.Key : Any]? {
                    let text: String = (element as? LabelInfo)?.text ?? "Body"
                    label.attributedText = NSAttributedString(string: text.firstUppercased, attributes: formatting)
                    generatedLabels.append(label)
                    generatedBackgroundView.addSubview(label)
                    // for animation
                    label.frame.size.width = 0
                    animateLabelIn(label: label, width: element.elementBoundingBox.width)
                }
            }
            // MARK: TODO complete for the remaining element types
        }
        
         overrideUserInterfaceStyle = .light
        
        // animate in UIButton for magic wand
        magicWandButton = UIButton(frame: CGRect(x: 702, y: 922, width: 88, height: 88))
        magicWandButton.setImage(UIImage(named: "wand"), for: .normal)
        magicWandButton.layer.shadowPath = UIBezierPath(rect: magicWandButton.bounds).cgPath
        magicWandButton.layer.shadowRadius = 50
        magicWandButton.layer.shadowOffset = .zero
        magicWandButton.layer.shadowOpacity = 0.9
        magicWandButton.alpha = 0
        view.addSubview(magicWandButton)
        magicWandButton.addTarget(self, action: #selector(WandButtonDidTap), for: .touchUpInside)
        
        animateSubViewIn(subView: magicWandButton, duration: 2.5, delay: 1.0)
        
        magicWandLabel = UILabel(frame: CGRect(x: 702, y: 1020, width: 88, height: 21))
        magicWandLabel.text = "UI Wand"
        magicWandLabel.textAlignment = .center
        magicWandLabel.backgroundColor = .white
        magicWandLabel.textColor = UIColor.link
        magicWandLabel.layer.cornerRadius = 5
        magicWandLabel.clipsToBounds = true
        magicWandLabel.alpha = 0
        view.addSubview(magicWandLabel)
        
        animateSubViewIn(subView: magicWandLabel, duration: 2.5, delay: 1.1)
    }
    
    func adjustFontLabelBannerView() {
        for subview in generatedBackgroundView.subviews {
            if let imageView = (subview as? UIImageView) {
                let nestedLabels = generatedBackgroundView.subviews.filter({imageView.frame.intersects($0.frame) && $0 is UILabel})
                for label in nestedLabels as? [UILabel] ?? [] {
                    // get frame relative to generatedBackgroundView
                    var frame = label.frame
                    // set relative to origin of the imageView istelf
                    frame.origin.y += imageView.frame.minY

                    let croppedImageView = imageView.asImage().crop(into: frame)
                    let backgroundImageColour = croppedImageView?.averageColor

                    var labelFontColour = label.textColor
                    
                    let currentFontColourContrast = getContrast(labelFontColour, backgroundImageColour)
                    labelFontColour = labelFontColour == .white ? .black : .white
                    let toggledFontColourContrast = getContrast(labelFontColour, backgroundImageColour)

                    if toggledFontColourContrast > currentFontColourContrast {
                        invertLabelColour(label: label)
                    }
                }
            }
        }
    }
    
    func getContrast(_ foreground: UIColor?, _ background: UIColor?) -> CGFloat {
        
        guard let foreground = foreground, let background = background else {
            return 0
        }
        
        var foregroundRGB = RGBComponents()
        var backgroundRGB = RGBComponents()
        
        if foreground == .white {
            foregroundRGB = RGBComponents(red: 1, green: 1, blue: 1)
        }
        else if foreground == .black {
            foregroundRGB = RGBComponents(red: 0, green: 0, blue: 0)
        }
        else {
            if foreground.cgColor.numberOfComponents > 2 {
                foregroundRGB = RGBComponents(red: foreground.cgColor.components?[0] ?? 0, green: foreground.cgColor.components?[1] ?? 0, blue: foreground.cgColor.components?[2] ?? 0)
            }
            else {
                return 0
            }
        }
        
        if background == .white {
            backgroundRGB = RGBComponents(red: 1, green: 1, blue: 1)
        }
        else if background == .black {
            backgroundRGB = RGBComponents(red: 0, green: 0, blue: 0)
        }
        else {
            if background.cgColor.numberOfComponents > 2 {
                backgroundRGB = RGBComponents(red: background.cgColor.components?[0] ?? 0, green: background.cgColor.components?[1] ?? 0, blue: background.cgColor.components?[2] ?? 0)
            }
            else {
                return 0
            }
        }
        
        var contrast: CGFloat = 0
        contrast += abs(foregroundRGB.red - backgroundRGB.red)
        contrast += abs(foregroundRGB.green - backgroundRGB.green)
        contrast += abs(foregroundRGB.blue - backgroundRGB.blue)
        
        return contrast*255/3
    }
    
    func invertLabelColour(label: UILabel) {
        if label.textColor == .white {
            label.textColor = .black
        }
        else {
            label.textColor = .white
        }
    }
    
    func setupGeneratedBackgroundView() {
        generatedBackgroundView.frame = canvasView.frame
        view.insertSubview(generatedBackgroundView, belowSubview: canvasView)
    }
    
    func getImageMetaData(imageName: String, type: ImageType, imageView: UIImageView, animateIn: Bool = false, isImageBannerView: Bool = false) {
        guard var baseURL = URLComponents(string: "https://api.unsplash.com/search/photos")
            else {return}
        
        var queryItems = [
            URLQueryItem(name: "client_id", value: "gI__Sfd5xYLEyAzmkvik77PEPVZKFdZ-_5apCYkTEp4"),
            URLQueryItem(name: "query", value: imageName),
            URLQueryItem(name: "content_filter", value: "high"),
            URLQueryItem(name: "count", value: "5"),
        ]
            
        if type == .Landscape || imageName == "golf" {
            queryItems.append(URLQueryItem(name: "orientation", value: "landscape"))
        }
        else if type == .Square {
            queryItems.append(URLQueryItem(name: "orientation", value: "squarish"))
        }

        baseURL.queryItems = queryItems
        let completeURL = baseURL.url!
        
        print("URL: \(completeURL)")
        
        let task = URLSession.shared.dataTask(with: completeURL) {(data, response, error) in
            guard let data = data else {return}
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let parsedJson = json["results"] as! [[String: Any]]
                    
                    var downloadedImages: [ImageData] = []
                    
                    for i in 0...4 {
                        // filter top 5 results
                        // avoid index out of range issue
                        if i > parsedJson.count - 1 {
                            break
                        }
                        
                        if let imageLinks = parsedJson[i]["urls"] as? [String: Any] {
                            
                            var link = URL(string: imageLinks["small"] as! String)!
                            if type == .Landscape {
                                link = URL(string: imageLinks["regular"] as! String)!
                            }
                            let description = parsedJson[i]["alt_description"] as? String ?? "Image of \(imageName)"
                            let image: UIImage = self.getImage(from: link)
                            
                            DispatchQueue.main.async {
                                if imageName == "walks" && i == 1 {
                                    imageView.image = image
                                    imageView.accessibilityLabel = description
                                    imageView.isAccessibilityElement = true

                                    // only after image has been set
                                    if animateIn {
                                        self.animateSubViewIn(subView: imageView, isImageBannerView: isImageBannerView)
                                    }
                                }
                                else if imageName == "golf" && i == 2 {
                                    imageView.image = image
                                    imageView.accessibilityLabel = description
                                    imageView.isAccessibilityElement = true

                                    if animateIn {
                                        self.animateSubViewIn(subView: imageView, isImageBannerView: isImageBannerView)
                                    }
                                }
                                else if i == 0 {
                                    imageView.image = image
                                    imageView.accessibilityLabel = description
                                    imageView.isAccessibilityElement = true

                                    if animateIn {
                                        self.animateSubViewIn(subView: imageView, isImageBannerView: isImageBannerView)
                                    }
                                }
                                downloadedImages.append(ImageData(image: image, description: description, type: type, position: imageView.frame))
                            }
                        }
                    }
                    self.imageDictionaries[imageName] = downloadedImages
                }
                
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func getImage(from url: URL) -> UIImage {
        let data = try! Data(contentsOf: url)
        return UIImage(data: data)!
    }
    
    func animateSubViewIn(subView: UIView, duration: TimeInterval = 2.0, delay: TimeInterval = 0.0, isImageBannerView: Bool = false) {
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
            subView.alpha = 1
        }, completion: { _ in
            if isImageBannerView {
                self.adjustFontLabelBannerView()
            }
        })
    }
    
    func animateLabelIn(label: UILabel, width: CGFloat) {
        let labelX: CGFloat = label.frame.minX
        let labelY: CGFloat = label.frame.minY
        let labelWidth: CGFloat = width
        let labelHeight: CGFloat = label.frame.size.height
        
        UIView.animate(withDuration: 3.0, delay: self.labelAnimationDelay * 0.05, options: .curveEaseInOut, animations: {
            label.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }, completion: nil)
        
        labelAnimationDelay += 10
    }
}


struct RGBComponents {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
}


// https://stackoverflow.com/questions/30696307/how-to-convert-a-uiview-to-an-image
extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
