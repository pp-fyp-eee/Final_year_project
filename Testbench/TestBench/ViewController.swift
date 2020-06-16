//
//  ViewController.swift
//  TestBench
//
//  Created by Pranav Paul on 12/06/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    var frames: [CGRect] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        predictRandomForest()
        predictImage()
    }
    
    func predictRandomForest() {
        let frame = CGRect(x: 5.364984439898140556e-01, y: 2.043237961895563448e-01, width: 2.640609741210937500e+01, height: 4.879931640625000000e+01)
        frames = Array(repeating: frame, count: 100)
        
        // MARK: import model and set name below
        let drawingClassifier = ForestDrawingClassifier() // set model name here
        
        let startTime = Date()
        
        for element in frames {
            let input = ForestDrawingClassifierInput(min_X: Double(element.minX), min_Y: Double(element.minY), width: Double(element.width), height: Double(element.height))
            let _ = try! drawingClassifier.prediction(input: input)
        }
        
        let timeTaken = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
        print(timeTaken)
        
    }
    
    func predictImage() {
        let image = UIImage(named: "1")

        let startTime = Date()
        
        for _ in 0..<100 {
            // MARK: import model and set name below
            let model = try! VNCoreMLModel(for: _6hidden().model) // set model name here
            let request = VNCoreMLRequest(model: model)
            request.imageCropAndScaleOption = .scaleFit
            let requestHandler = VNImageRequestHandler(cgImage: image!.cgImage!, options: [:])
            try? requestHandler.perform([request])
            let _ = request.results as? [VNClassificationObservation]
        }
        
        let timeTaken = Date().timeIntervalSince1970 - startTime.timeIntervalSince1970
        print(timeTaken)
    }

}

