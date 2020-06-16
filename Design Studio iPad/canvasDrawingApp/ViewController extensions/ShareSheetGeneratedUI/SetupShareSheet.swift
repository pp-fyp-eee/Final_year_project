//
//  SetupShareSheet.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 08/06/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

extension ViewController {
    
    func setupShareSheetGeneratedUI() {
        let shareButton: UIButton = UIButton(frame: CGRect(x: 702, y: 28, width: 88, height: 88))
        shareButton.setImage(UIImage(named: "share_icon_white_background"), for: .normal)
        shareButton.layer.shadowPath = UIBezierPath(rect: shareButton.bounds).cgPath
        shareButton.layer.shadowRadius = 50
        shareButton.layer.shadowOffset = .zero
        shareButton.layer.shadowOpacity = 0.9
        shareButton.showsTouchWhenHighlighted = true
        view.addSubview(shareButton)
        shareButton.addTarget(self, action: #selector(shareButtonDidTap), for: .touchUpInside)
        
        let shareLabel: UILabel = UILabel(frame: CGRect(x: 718, y: 125, width: 62, height: 31))
        shareLabel.text = "Share"
        shareLabel.textAlignment = .center
        shareLabel.backgroundColor = .white
        shareLabel.textColor = UIColor.link
        shareLabel.layer.cornerRadius = 5
        shareLabel.clipsToBounds = true
        view.addSubview(shareLabel)
        
    }
    
    @objc func shareButtonDidTap() {
        guard let image = view.asImage().crop(into: CGRect(x: 330, y: 170, width: 1000, height: 2150)) else {return}
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)

        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 750, y: 160, width: 0, height: 0)
        activityViewController.popoverPresentationController?.permittedArrowDirections = .up
        self.present(activityViewController, animated: true, completion: nil)
    }
}
