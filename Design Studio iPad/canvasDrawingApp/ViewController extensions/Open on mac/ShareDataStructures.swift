//
//  ShareDataStructures.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 31/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

struct DataToSend: Codable {
    var frame: CGRect
    // for labels
    var text: String?
    var attributedText: String?
    // for buttons
    var buttonImage: String?
    // for imageViews
    var image: String?
    var accessibilityLabel: String?    
}


struct LabelDataToSend: Codable {
    var frame: CGRect
    var text: String = ""
    var attributes: String = ""
}

struct ButtonDataToSend: Codable {
    var frame: CGRect
    var image: Data?
    
    mutating func setImageData(image: UIImage) {
        self.image = image.pngData()
    }
}
