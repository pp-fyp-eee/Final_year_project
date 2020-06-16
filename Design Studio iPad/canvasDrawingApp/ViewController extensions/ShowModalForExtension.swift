//
//  ShowModalForExtension.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 08/06/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

extension ViewController {
    
    func showModal(image: UIImage) {
         let modalViewController = EditingViewController()
         modalViewController.isModalInPresentation = true
         modalViewController.selectedImage = image
         present(modalViewController, animated: true, completion: nil)
     }
}
