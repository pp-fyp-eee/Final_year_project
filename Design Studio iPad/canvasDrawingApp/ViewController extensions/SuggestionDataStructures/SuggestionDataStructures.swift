//
//  SuggestionDataStructures.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 29/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

struct SuggestionDescription {
    let title: String
    var message: String
}

struct SuggestedElements {
    var suggestedView: UIView
    var description: SuggestionDescription
}

