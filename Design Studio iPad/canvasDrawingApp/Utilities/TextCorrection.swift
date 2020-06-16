//
//  TextCorrection.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 25/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//
//  Reference: https://nshipster.com/uitextchecker/

import UIKit

struct TextCorrection {
    
    // returns true if given word is in the iOS dictionary for the given language
    func wordIsInDictionary(word: String, language: String = "en_GB") -> Bool {
        let misspelledRange = createMisspelledRange(word: word, language: language)
        return misspelledRange.location == NSNotFound
    }
    
    func suggestedWord(word: String, language: String = "en_GB") -> String? {
        let textChecker = UITextChecker()
        let wordRange = NSRange(0..<word.utf16.count)
        let misspelledRange = textChecker.rangeOfMisspelledWord(in: word, range: wordRange, startingAt: 0, wrap: false, language: language)
        
        if misspelledRange.location != NSNotFound {
            if let firstGuess = textChecker.guesses(forWordRange: misspelledRange, in: word, language: language) {
                return firstGuess.isEmpty ? nil: firstGuess[0]
            }
        }
        return nil
    }
    
    private func createMisspelledRange(word: String, language: String) -> NSRange {
        let textChecker = UITextChecker()
        let wordRange = NSRange(0..<word.utf16.count)
        let misspelledRange = textChecker.rangeOfMisspelledWord(in: word, range: wordRange, startingAt: 0, wrap: false, language: language)
        return misspelledRange
    }

}
