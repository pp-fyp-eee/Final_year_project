//
//  DrawingStructures.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 19/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

enum DrawingType {
    case tableViewCell
    case imageBannerView
    case imageCellView
    case letter
    case symbol
    case switchButton
}

enum SymbolType {
    case magnifying_glass
    case profile
    case location
}

struct DrawingStrokeData {
    var type: DrawingType
    var data: String? = nil
    var strokes: [CGPoint] = []
}

protocol Drawings {
    var elementBoundingBox: CGRect {get set}
}

struct DrawingInfo: Drawings {
    var type: DrawingType
    var data: Any?
    var elementBoundingBox: CGRect
}

enum LabelType {
    case title
    case subtitle
    case imageBannerViewLabel
    case body
    case buttonDescriptor
}

struct LabelInfo: Drawings {
    var text: String = ""
    var elementBoundingBox: CGRect
    var labelType: LabelType?
    var formatting: [NSAttributedString.Key : Any]?
}
