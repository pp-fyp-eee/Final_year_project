//
//  ApplyTextCorrection.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 25/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

extension ViewController {
    
    func applyTextCorrection() {
        
        let textCorrection = TextCorrection()
        
        var i = 0
        
        while i < labels.count {
            if !textCorrection.wordIsInDictionary(word: labels[i].text) {
                // not in dictionary
                if let suggestedWord = textCorrection.suggestedWord(word: labels[i].text) {
                    labels[i].text = suggestedWord
                }
            }
            i += 1
        }
    }
}
