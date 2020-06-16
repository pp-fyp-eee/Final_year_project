//
//  Constants.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 19/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

class Constants {

    struct Colors {
        static let buttonBlue: UIColor = UIColor(red: 0.01176470588, green: 0.4784313725, blue: 1.0, alpha: 1.0)
    }
    
    struct Drawings {
        // between characters
        static let horizontalThreshold: CGFloat = 40
        static let verticalThreshold: CGFloat = 40
        
        // for title from top of associated view
        static let titleDistanceThreshold: CGFloat = 100
    }
    
    struct LabelFormation {
        // spacing between different words
        static let horizontalThreshold: CGFloat = 40
        static let verticalThreshold: CGFloat = 40
    }
    
    struct TextFormatting {
        static func getTitleFormatting() -> [NSAttributedString.Key : Any] {
            return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 45, weight: .bold)] as [NSAttributedString.Key : Any]
        }
        static func getSubTitleFormatting() -> [NSAttributedString.Key : Any] {
            return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35, weight: .bold)] as [NSAttributedString.Key : Any]
        }
        static func getImageBannerViewTextFormatting(fontColor: UIColor = .white) -> [NSAttributedString.Key : Any] {
            return [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40, weight: .bold),
                NSAttributedString.Key.foregroundColor: fontColor
                ] as [NSAttributedString.Key : Any]
        }
        static func getBodyFormatting() -> [NSAttributedString.Key : Any] {
            return [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .semibold)] as [NSAttributedString.Key : Any]
        }
        static func getButtonLabelFormatting() -> [NSAttributedString.Key : Any] {
            return [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold),
                NSAttributedString.Key.foregroundColor: Constants.Colors.buttonBlue
                ] as [NSAttributedString.Key : Any]
        }
    }
    
    struct ViewCornerRadius {
        static let radius: CGFloat = 5
    }
    
}

// from https://stackoverflow.com/questions/26306326/swift-apply-uppercasestring-to-only-the-first-letter-of-a-string
extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
}

extension UIColor {
    static let boundaryGreenColor: UIColor = UIColor(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 1.0)
}
