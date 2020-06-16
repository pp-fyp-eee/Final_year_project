//
//  ViewController.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 20/03/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit
import CoreML
import Vision
import PencilKit
import MultipeerConnectivity

class ViewController: UIViewController, PKCanvasViewDelegate {
    
    @IBOutlet weak var canvasView: PKCanvasView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var backToProjectsButton: UIButton!
    
    var currentSentence: String = ""
    var newLetterIsDrawn = false
    var classifiedLastLetter = false
    var insertSpace = false
    var finishedPreviousLabel = false
    
    var dataset: [CGImage] = []
    
    var drawings: [DrawingStrokeData] = []
    var drawingInfo: [DrawingInfo] = []
    var didAppend = false
    var currentIndex = 0
    
    var previousStrokes: [CGPoint] = []
    var currentStrokes: [CGPoint] = []
    var minPreviousStroke: CGPoint = CGPoint()
    var maxPreviousStroke: CGPoint = CGPoint()
    var minBackgroundPosition = CGPoint()
    var maxBackgroundPosition = CGPoint()
    var heightPreviousStroke: CGFloat = 0
    var widthPreviousStroke: CGFloat = 0
    
    
    // for labels array (getLabels method)
    var labels: [LabelInfo] = []
    var nonLabelElements: [DrawingInfo] = []
    var imageViews: [DrawingInfo] = []
    var buttons: [DrawingInfo] = []
    var finalElementPositions: [Drawings] = []
    
    // View for final elements
    let generatedBackgroundView: UIView = UIView()
    var generatedButtons: [UIButton] = []
    var generatedLabels: [UILabel] = []
    var imageDictionaries: [String : [ImageData]] = [:] // for popovers
    var generatedImageViews: [UIImageView] = []
    
    var labelAnimationDelay: Double = 0
    
    var magicWandButton: UIButton = UIButton()
    var magicWandLabel: UILabel = UILabel()
    
    // for suggestions
    var buttonDescriptionExists: Bool = false
    var suggestions: [SuggestedElements] = []
    
    // for sending data
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser!
    var dataStringToSend: String = ""
    
    // when to analyse tap locations
    var didShowSuggestions: Bool = false
    var tappedView: UIView = UIView()
    var tappedDrawing: DrawingInfo?
    // for protocol when dismissing popover for images
    var selectedIndex: Int = 0
    var didSelectImageFromLibrary: Bool = false
    var selectedImage: UIImage?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
     

    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupCanvasView()
        setupBackgroundImageView()
        setupButton(button: generateButton)
        setupButton(button: backToProjectsButton)
    }
    
    private func setupCanvasView() {
        canvasView.delegate = self
        canvasView.tool = PKInkingTool(.pen, color: .darkGray, width: 10)
        canvasView.allowsFingerDrawing = false
        canvasView.isUserInteractionEnabled = true
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.layer.cornerRadius = 20
        canvasView.clipsToBounds = true // for corner radius
    }
    
    private func setupBackgroundImageView() {
        let backgroundImageView = UIImageView(frame: view.frame)
        backgroundImageView.image = UIImage(named: "blueprint_background")
        view.insertSubview(backgroundImageView, at: 0)
    }
    
    private func setupButton(button: UIButton) {
        let blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = button.bounds
        blurView.isUserInteractionEnabled = false
        button.backgroundColor = .clear
        button.insertSubview(blurView, at: 0)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        button.setTitleColor(.white, for: .normal)
        view.bringSubviewToFront(button)
    }
    
    @IBAction func clearButtonDidPress(_ sender: Any) {
        print("clearing drawing")
        canvasView.drawing = PKDrawing()
        currentStrokes = []
        previousStrokes = []
        currentSentence = ""
    }
    
    // during drawing => where to position the elements (including text)
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        for touch in touches {
            currentStrokes.append(touch.preciseLocation(in: canvasView))
        }
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        previousStrokes = currentStrokes
        currentStrokes = []
        newLetterIsDrawn = true
        classifiedLastLetter = false
    }
    
    // after stroke is completed => classify
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        if doesIntersect() {
            previousStrokes.append(contentsOf: currentStrokes)
            _ = doesIntersect()
            currentStrokes = []
        }
        
        let boundingBox = CGRect(x: minPreviousStroke.x, y: minPreviousStroke.y, width: widthPreviousStroke, height: heightPreviousStroke)
        
        let classifiedDrawing = classifyDrawing()

        if classifiedDrawing == DrawingType.letter {
            classifyLetter()
        }
        else if let classifiedDrawing = classifiedDrawing {
            drawingInfo.append(DrawingInfo(type: classifiedDrawing, data: nil, elementBoundingBox: boundingBox))
        }
    }
    
    private func classifyDrawing() -> DrawingType? {
        if previousStrokes.isEmpty {
            return nil
        }
        
        let drawingClassifier = ForestDrawingClassifier()
        
        let minX = minPreviousStroke.x + 201 // canvasView offset in view
        let minY = minPreviousStroke.y + 132 // canvasView offset in view
        let width = maxPreviousStroke.x - minPreviousStroke.x
        let height = maxPreviousStroke.y - minPreviousStroke.y
        
        let input = ForestDrawingClassifierInput(min_X: Double(minX/canvasView.frame.maxX), min_Y: Double(minY/canvasView.frame.maxY), width: Double(width), height: Double(height))
        
        let prediction = try! drawingClassifier.prediction(input: input)
        let probabilities = prediction.classProbability
    
        guard let maxProbability = probabilities.max(by: {$0.value < $1.value}) else {
            return nil
        }
        print("Class: \(String(describing: maxProbability.key))")
        
        switch maxProbability.key {
        case 0:
            return .tableViewCell
        case 1:
            return .imageBannerView
        case 2:
            return .imageCellView
        case 3:
            return .letter
        case 4:
            return .symbol
        case 5:
            return .switchButton
        default:
            return nil
        }
    }
    
    private func classifyLetter() {
        if previousStrokes.isEmpty {
            return
        }
        // MARK: model selection
        let model = try! VNCoreMLModel(for: custom_model_17().model)
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .scaleFit
        
        
        let boundingBox = CGRect(x: minPreviousStroke.x, y: minPreviousStroke.y, width: widthPreviousStroke, height: heightPreviousStroke)
        
        var image = canvasView.drawing.image(from: boundingBox, scale: 1.0)
        image = image.scaleImage(size: CGSize(width: 28, height: 28))
        
        let cgImage = image.convertToGrayscale()
     
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([request])
        
        let results = request.results as? [VNClassificationObservation]
        
        guard let identifier = results?.first!.identifier
        else {
            return
        }
        
        print(identifier)
        let letterDrawingInfo = DrawingInfo(type: .letter, data: String(identifier), elementBoundingBox: boundingBox)
        drawingInfo.append(letterDrawingInfo)
        
        dataset.append(cgImage)
    }
    
    private func doesIntersect() -> Bool {
        
        if previousStrokes.isEmpty {
            return false
        }
        
        minPreviousStroke = previousStrokes[0]
        maxPreviousStroke = minPreviousStroke
        
        for pStroke in previousStrokes {
            if pStroke.x < minPreviousStroke.x {
                minPreviousStroke.x = pStroke.x
            }
            if pStroke.y < minPreviousStroke.y {
                minPreviousStroke.y = pStroke.y
            }
            if pStroke.x > maxPreviousStroke.x {
                maxPreviousStroke.x = pStroke.x
            }
            if pStroke.y > maxPreviousStroke.y {
                maxPreviousStroke.y = pStroke.y
            }
        }
        
        // width of pen
        minPreviousStroke.x -= 4
        minPreviousStroke.y -= 15 
        
        widthPreviousStroke = maxPreviousStroke.x - minPreviousStroke.x + 5
        heightPreviousStroke = maxPreviousStroke.y - minPreviousStroke.y + 5
        
        let boundingBox = CGRect(x: minPreviousStroke.x, y: minPreviousStroke.y, width: widthPreviousStroke, height: heightPreviousStroke)
        
        if previousStrokes.isEmpty || currentStrokes.isEmpty {
            return false
        }
        
        if classifyDrawing() != .letter {
            return false
        }
        
        var minCurrentStroke = currentStrokes[0]
        var maxCurrentStroke = minCurrentStroke
        
        for cStroke in currentStrokes {
            if boundingBox.contains(cStroke) {
                return true
            }
            if cStroke.x < minCurrentStroke.x {
                minCurrentStroke.x = cStroke.x
            }
            if cStroke.y < minCurrentStroke.y {
                minCurrentStroke.y = cStroke.y
            }
            if cStroke.x > maxCurrentStroke.x {
                maxCurrentStroke.x = cStroke.x
            }
            if cStroke.y > maxCurrentStroke.y {
                maxCurrentStroke.y = cStroke.y
            }
        }
  
        // no overlap present
        // avoid expensive sqrt() operation
        // MARK: check vertical distance in og code
    
        let horizontalDistance = minCurrentStroke.x - maxPreviousStroke.x
        let verticalDistance = maxPreviousStroke.y - maxCurrentStroke.y

        print("Horizontal distance is: \(horizontalDistance)")
        print("Vertical distance is: \(verticalDistance)")
        
        if horizontalDistance > Constants.Drawings.horizontalThreshold || verticalDistance > Constants.Drawings.verticalThreshold {
            print("New label at updated position")
            finishedPreviousLabel = true
        }
        else {
            // still on current label
            // update background view position
            if minPreviousStroke.x < minBackgroundPosition.x {
                minBackgroundPosition.x = minPreviousStroke.x
            }
            if minPreviousStroke.y < minBackgroundPosition.y {
                minBackgroundPosition.y = minPreviousStroke.y
            }
            if maxPreviousStroke.x > maxBackgroundPosition.x {
                maxBackgroundPosition.x = maxPreviousStroke.x
            }
            if maxPreviousStroke.y > maxBackgroundPosition.y {
                maxBackgroundPosition.y = maxPreviousStroke.y
            }
            finishedPreviousLabel = false
        }
        
        return false
    }
    
    @IBAction func doneDidTap(_ sender: Any) {
        previousStrokes = currentStrokes
        currentStrokes = []
        newLetterIsDrawn = true
        classifiedLastLetter = false
        
        canvasViewDrawingDidChange(canvasView)
        
        for element in dataset.reversed() {
            // use breakpoint to view final image being passed to model
            print(element.alphaInfo)
        }
        
        classifySymbol()
        
        print(drawingInfo)
        for element in drawingInfo {
            print("Type: \(element.type)")
            if let data = element.data {
                print("Data: \(data)")
            }
            print("Position:  \(element.elementBoundingBox) \n\n")
        }
        
        // filter non-label elements
        populateNonLabelElements()
        
        // form labels from handwritten letters
        populateLabels()
        
        // apply iOS auto-correction (if word is not in the iOS dictionary)
        applyTextCorrection()
        
        // find corresponding text label for all imageBanner and imageCell views
        findCorrespondingImageViewText()
        
        // find corresponding text label for all buttons (if user has included them)
        findCorrespondingButtonText()
        
        // figure out which labels are titles and/or subtitles
        classifyTitleAndSubtitleLabels()
        
        // update final positions based on where the user drew the UI elements
        getFinalElementPositions()
        
        // insert generated views
        insertGeneratedViews()
        
    }
    
    private func classifySymbol() {
        
        var symbols: [CGRect] = []
        
        // filter out the bounding boxes of symbol elements
        var i = 0
        while i < drawingInfo.count {
            if drawingInfo[i].type == .symbol {
                let symbol = drawingInfo.remove(at: i).elementBoundingBox
                symbols.append(symbol)
            }
            else {
                i += 1
            }
        }
        
        if symbols.count == 0 {
            return
        }
        
        // find union
        var symbol_bounding_box = symbols.first!
        
        for symbol in symbols {
            if symbol_bounding_box.contains(symbol) || symbol_bounding_box.intersects(symbol) {
                symbol_bounding_box = symbol_bounding_box.union(symbol)
            }
        }
        
        
        // pass through model
        
        // MARK: model selection
        let model = try! VNCoreMLModel(for: SymbolClassifier().model)
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .scaleFit
        
        var image = canvasView.drawing.image(from: symbol_bounding_box, scale: 1.0)
        image = image.scaleImage(size: CGSize(width: 28, height: 28))
        
        let cgImage = image.convertToGrayscale()
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([request])
        
        let results = request.results as? [VNClassificationObservation]
        
        guard let identifier = results?.first!.identifier
            else {
                return
        }

        print(identifier)
        
        var symbolClass: SymbolType? = nil
        
        if identifier == "magnifying_glass" {
            symbolClass = .magnifying_glass
        }
        else if identifier == "profile" {
            symbolClass = .profile
        }
        else if identifier == "location" {
            symbolClass = .location
        }
        
        let symbolInformation = DrawingInfo(type: .symbol, data: symbolClass, elementBoundingBox: symbol_bounding_box)
        drawingInfo.append(symbolInformation)
    }
}
