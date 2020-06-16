//
//  EditingViewController.swift
//  DesignStudio
//
//  Created by Pranav Paul on 06/06/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit
import PencilKit
import CoreML
import Vision
import AVFoundation

enum EditingModeDrawing {
    case swiggle
    case UIswitch
    case magnifyingGlass
}

enum EditType {
    case insertion
    case deletion
}

class EditingViewController: UIViewController, PKCanvasViewDelegate {

    var selectedImage: UIImage = UIImage()
    var imageView: UIImageView = UIImageView()
    var canvasView: PKCanvasView = PKCanvasView()
    
    var topTableViewPosition: CGPoint?
    var numberOfMajorCells: Int = 0
    var spacingBetweenMajorCells: CGFloat = 0
    var tableViewElementPositions: [String:[CGRect]] = [:]
    
    var didIntersect = false
    var previousStrokes: [CGPoint] = []
    var currentStrokes: [CGPoint] = []
    
    var minPreviousStroke: CGPoint = CGPoint()
    var maxPreviousStroke: CGPoint = CGPoint()
    var widthPreviousStroke: CGFloat = 0
    var heightPreviousStroke: CGFloat = 0
    
    var editLog: [String] = []
    
    private var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // MARK: have to add in all subviews programmatically
        view.backgroundColor = .white
        print(view.frame)
        
        imageView = UIImageView(frame: CGRect(x: 135.5, y: 115, width: 438, height: 875))
        imageView.image = selectedImage
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        
        // MARK: intialise dictionary with keys - output of model
        tableViewElementPositions["button_tableView"] = []
        
        
        // for image
        passBackgroundImageThroughModel(image: selectedImage, imageView: imageView)
        
        setupCanvasView(frame: imageView.frame)
        setupCloseButton()
        setupShareButton()
    }
    
    func setupCanvasView(frame: CGRect) {
        canvasView.frame = frame
        canvasView.delegate = self
        canvasView.tool = PKInkingTool(.pen, color: .darkGray, width: 10)
        canvasView.allowsFingerDrawing = false
        canvasView.isUserInteractionEnabled = true
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        view.addSubview(canvasView)
    }
    
    func setupCloseButton() {
        let cancelButton = UIButton(frame: CGRect(x: 60, y: 33, width: 50, height: 50))
        cancelButton.setImage(UIImage(named: "close_button"), for: .normal)
        cancelButton.showsTouchWhenHighlighted = true
        view.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(closeButtonDidTap), for: .touchUpInside)
        
        let closeLabel = UILabel(frame: CGRect(x: 58, y: 94, width: 55, height: 16))
        closeLabel.text = "Close"
        closeLabel.textAlignment = .center
        closeLabel.textColor = UIColor(red: 0.5607, green: 0.5607, blue: 0.5607, alpha: 1.0)
        view.addSubview(closeLabel)
    }
    
    @objc func closeButtonDidTap() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func setupShareButton() {
        let shareButton = UIButton(frame: CGRect(x: 616, y: 21, width: 35, height: 47))
        shareButton.setImage(UIImage(named: "share_button"), for: .normal)
        shareButton.showsTouchWhenHighlighted = true
        view.addSubview(shareButton)
        shareButton.addTarget(self, action: #selector(shareButtonDidTap), for: .touchUpInside)
        
        let shareLabel = UILabel(frame: CGRect(x: 606, y: 77, width: 55, height: 21))
        shareLabel.text = "Share"
        shareLabel.textAlignment = .center
        shareLabel.textColor = .link
        view.addSubview(shareLabel)
    }
    
    @objc func shareButtonDidTap() {

        // relative to super view (ViewController.view)
        guard let image = view.asImage().crop(into: CGRect(x: 198, y: 200, width: 1038, height: 875*2.5)) else {return}
        var dataToSend: [Any] = [image]
        dataToSend.append(contentsOf: editLog)
        
        let activityViewController = UIActivityViewController(activityItems: dataToSend, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 626, y: 100, width: 0, height: 0)
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
        
        if !didIntersect {
            previousStrokes = currentStrokes
        }
        currentStrokes = []
    }
    
    
    // during drawing => where to position the elements (including text)
    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
        for touch in touches {
            currentStrokes.append(touch.preciseLocation(in: canvasView))
        }
    }
    
    
    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
        
        // check if previous strokes intersect with currentStrokes, if they do not, then set finished drawing to true
        if doesIntersect() {
            print("intersects")
            previousStrokes.append(contentsOf: currentStrokes)
            _ = doesIntersect()
            currentStrokes = []

            didIntersect = true
            // cancel previous task
            workItem?.cancel()
        }
        else {
            didIntersect = false
            previousStrokes = currentStrokes
            _ = doesIntersect()
        }

        workItem = DispatchWorkItem(block: {
            print("classifying")
            
            let boundingBox = CGRect(x: self.minPreviousStroke.x, y: self.minPreviousStroke.y, width: self.widthPreviousStroke, height: self.heightPreviousStroke)
            let preProcessedImage = self.getPreprocessedImage(from: boundingBox)
            let (edit, drawing) = self.classifyDrawing(image: preProcessedImage)
            // unwrap optionals
            guard let editMode = edit, let drawingData = drawing else {return}
            self.editBackgroundImage(mode: editMode, drawing: drawingData, frame: boundingBox)
            print("acting (inserting/removing)")
            print("clearing")
            // reset all drawing info
            canvasView.drawing = PKDrawing()
            self.previousStrokes = []
            self.currentStrokes = []
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: workItem!)
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
        minPreviousStroke.y -= 15 //13
        
        widthPreviousStroke = maxPreviousStroke.x - minPreviousStroke.x + 5
        heightPreviousStroke = maxPreviousStroke.y - minPreviousStroke.y + 5
    
        if currentStrokes.isEmpty {
            return false
        }
        
        let boundingBox = CGRect(x: minPreviousStroke.x, y: minPreviousStroke.y, width: widthPreviousStroke, height: heightPreviousStroke)
        
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
        
        return false
    }
    
    
    private func passBackgroundImageThroughModel(image: UIImage, imageView: UIImageView) {
        let model = try! VNCoreMLModel(for: UIElementsDetector().model)
        let request = VNCoreMLRequest(model: model)
        
        guard let cgImage = image.cgImage else {
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try? requestHandler.perform([request])
        
        guard let results = request.results else {return}
        let detections = results as! [VNRecognizedObjectObservation]
        print(detections)
        self.drawDetectionsOnPreview(detections: detections, image: image, imageView: imageView)
    }
    
    private func drawDetectionsOnPreview(detections: [VNRecognizedObjectObservation], image: UIImage, imageView: UIImageView) {

        var imageRect: CGRect!
        
        for detection in detections {
            let boundingBox = detection.boundingBox

            imageRect = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)

            var scaledBoundingBox = boundingBox
            scaledBoundingBox.origin.x *= imageRect.width
            scaledBoundingBox.origin.x += imageRect.minX + 5
            scaledBoundingBox.origin.y *= imageRect.height
            scaledBoundingBox.origin.y -= 77
            scaledBoundingBox.size.width *= imageRect.width
            scaledBoundingBox.size.width += 2.5
            scaledBoundingBox.size.height *= imageRect.height
            scaledBoundingBox.size.height += 10
                        
            let classifiedElementLabel = detection.labels.map({$0.identifier})[0]
            tableViewElementPositions[classifiedElementLabel]?.append(scaledBoundingBox)
            
            if topTableViewPosition == nil {
                topTableViewPosition = CGPoint(x: scaledBoundingBox.minX, y: scaledBoundingBox.minY)
            }
            else if scaledBoundingBox.minY < topTableViewPosition?.y ?? scaledBoundingBox.minY {
                topTableViewPosition = CGPoint(x: scaledBoundingBox.minX, y: scaledBoundingBox.minY)
            }
        }

        // update spacing between tableView cells
        guard let buttonPositions = tableViewElementPositions["button_tableView"] else {return}
        numberOfMajorCells = buttonPositions.count
        
        if buttonPositions.count < 2 {return}
        var verticalDistanceThreshold = abs(buttonPositions[0].minY - buttonPositions[1].minY)
        
        var i = 0
        while i < buttonPositions.count - 1 {
            let distance = abs(buttonPositions[i].minY - buttonPositions[i+1].minY)
            if distance < verticalDistanceThreshold {
                verticalDistanceThreshold = distance
            }
            i += 1
        }
        
        spacingBetweenMajorCells = verticalDistanceThreshold
    }
    
    
    private func getPreprocessedImage(from frame: CGRect) -> CGImage {
        var image = canvasView.drawing.image(from: frame, scale: 1.0)
        image = image.scaleImage(size: CGSize(width: 28, height: 28))
        return image.convertToGrayscale()
    }
    
    private func classifyDrawing(image: CGImage) -> (EditType?, EditingModeDrawing?) {
        
        let model = try! VNCoreMLModel(for: SymbolClassifierEditingMode().model)
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .scaleFit
        
        let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        try? requestHandler.perform([request])
        
        let results = request.results as? [VNClassificationObservation]
        
        guard let identifier = results?.first!.identifier else {return (nil, nil)}
        
        print(identifier)
        
        var drawing: EditingModeDrawing?
        var edit: EditType?
        
        if identifier == "swiggle" {
            drawing = .swiggle
            edit = .deletion
        }
        else if identifier == "switch" {
            drawing = .UIswitch
            edit = .insertion
        }
        else if identifier == "magnifying_glass" {
            drawing = .magnifyingGlass
            edit = .insertion
        }
        return (edit, drawing)
    }
    
    private func editBackgroundImage(mode: EditType, drawing: EditingModeDrawing, frame: CGRect) {
        switch mode {
        case .insertion:
            insertElement(element: drawing, at: frame)
            break
        case .deletion:
            deleteElement(element: drawing, at: frame)
            break
        }
    }
    
    private func insertElement(element: EditingModeDrawing, at frame: CGRect) {
        guard let topTableViewPosition = topTableViewPosition else {return}
        let tableViewHeightThreshold: CGFloat = 120
        if frame.minY > topTableViewPosition.y - tableViewHeightThreshold {
            // inside tableView
            insertElementIntoTableViewRows(element, at: frame)
        }
        else {
            // outside of tableView
            var updatedFrame = frame
            updatedFrame.origin.y += 15
            updatedFrame.size.width = 38
            updatedFrame.size.height = 38
            
            switch element {
            case .swiggle:
                return
            case .UIswitch:
                let switchElement = UISwitch(frame: updatedFrame)
                switchElement.isOn = true
                canvasView.addSubview(switchElement)
                editLog.append("[+] Inserted UISwitch at \(updatedFrame)\n")
                break
            case .magnifyingGlass:
                let imageViewToInsert = UIImageView(frame: updatedFrame)
                imageViewToInsert.image = UIImage(named: "zoom_icon")
                imageViewToInsert.contentMode = .scaleAspectFit
                canvasView.addSubview(imageViewToInsert)
                let descriptionLabel = UILabel(frame: CGRect(x: imageViewToInsert.frame.minX, y: imageViewToInsert.frame.maxY + 5, width: 60, height: 15))
                descriptionLabel.text = "Zoom"
                descriptionLabel.textColor = .link
                canvasView.addSubview(descriptionLabel)
                editLog.append("[+] Inserted magnifying zoom icon at \(updatedFrame)\n")
                break
            }
        }
    }
    
    private func insertElementIntoTableViewRows(_ element: EditingModeDrawing, at frame: CGRect) {
        
        var updateLog = "[+] Inserted "
        
        var updatedFrame = frame
        updatedFrame.origin.y += 15 // trim the spacing around the element created during 'doesIntersect' method
        
        var i = 0
        
        switch element {
        case .swiggle:
            return
        case .UIswitch:
            let switchElement = UISwitch(frame: updatedFrame)
            switchElement.isOn = true
            canvasView.addSubview(switchElement)
            while i < numberOfMajorCells - 1 {
                updatedFrame.origin.y += spacingBetweenMajorCells
                let switchElement = UISwitch(frame: updatedFrame)
                switchElement.isOn = true
                canvasView.addSubview(switchElement)
                i += 1
            }
            updateLog += "UISwitches into the TableView\n"
            editLog.append(updateLog)
            break
        case .magnifyingGlass:
            updatedFrame.size.width = 38
            updatedFrame.size.height = 38
            let imageViewToInsert = UIImageView(frame: updatedFrame)
            imageViewToInsert.image = UIImage(named: "zoom_icon")
            imageViewToInsert.contentMode = .scaleAspectFit
            canvasView.addSubview(imageViewToInsert)
            let descriptionLabel = UILabel(frame: CGRect(x: imageViewToInsert.frame.minX, y: imageViewToInsert.frame.maxY + 5, width: 60, height: 15))
            descriptionLabel.text = "Zoom"
            descriptionLabel.textColor = .link
            canvasView.addSubview(descriptionLabel)
            while i < numberOfMajorCells - 1 {
                updatedFrame.origin.y += spacingBetweenMajorCells
                let imageViewToInsert = UIImageView(frame: updatedFrame)
                imageViewToInsert.image = UIImage(named: "zoom_icon")
                imageViewToInsert.contentMode = .scaleAspectFit
                canvasView.addSubview(imageViewToInsert)
                let descriptionLabel = UILabel(frame: CGRect(x: imageViewToInsert.frame.minX, y: imageViewToInsert.frame.maxY + 5, width: 60, height: 15))
                descriptionLabel.text = "Zoom"
                descriptionLabel.textColor = .link
                canvasView.addSubview(descriptionLabel)
                i += 1
            }
            updateLog += "magnifying zoom icon into the TableView\n"
            editLog.append(updateLog)
            break
        }
    }
    
    private func deleteElement(element: EditingModeDrawing, at frame: CGRect) {
        // find element to delete
        for (elementKey, boundingBoxes) in tableViewElementPositions {
            for boundingBox in boundingBoxes {
                if boundingBox.intersects(frame) {
                    // found element to remove
                    deleteElementsfromTableViewRows(elementKey, at: boundingBox)
                    return
                }
            }
        }
    }
    
    private func deleteElementsfromTableViewRows(_ elementKey: String, at boundingBox: CGRect) {
        // look at all the same elements
        for position in tableViewElementPositions[elementKey] ?? [] {
            // within threshold distance below
            if abs(position.minX - boundingBox.minX) < 40 {
                let rectView = UIView(frame: position)
                rectView.backgroundColor = .white
                imageView.addSubview(rectView)
                editLog.append(" [-] Removed elementKey from the TableView\n")
            }
        }
    }
    
}
