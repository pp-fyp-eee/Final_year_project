//
//  ShareViewController.swift
//  ImageShareExtension
//
//  Created by Pranav Paul on 06/06/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//
// Reference: stackoverflow.com/questions/57644782/nsitemprovider-loaditem-method-returns-nsitemprovidersandboxedresource-instead

import UIKit
import MobileCoreServices

var selectedImage: UIImage = UIImage()
var updated: Bool = false

@objc(ShareExtensionViewController)
class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        handleFile()
    }
    
    func handleFile() {
        let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType = kUTTypeData as String
        for provider in attachments {
            
            if provider.hasItemConformingToTypeIdentifier(contentType) {
                provider.loadItem(forTypeIdentifier: contentType, options: nil) { [unowned self] (data, error) in
                    guard error == nil else { return }
                    if let url = data as? URL,
                        let imageData = try? Data(contentsOf: url) {
                        self.convertToUIImage(imageData)
                    } else {
                        fatalError("Couldn't save image, check the data is a image")
                    }
                }}
        }
    }
    
    func convertToUIImage(_ data: Data) {
        
        let defaults = UserDefaults(suiteName: "group.canvasDrawingApp.ShareContainer")
        defaults?.set(data, forKey: "imageData")
        
    }
    
    @IBAction func buttonDidTap(_ sender: Any) {
        
        self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
    }

}
