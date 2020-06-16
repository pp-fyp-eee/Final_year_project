//
//  ImageViewUtilities.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 23/03/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit

extension UIImage {
    
    var noir: UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!
        let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        return processedImage
    }
    
    // https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
        
    func scaleImage(size:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func convertToGrayscale() -> CGImage {
        let imageRect: CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(self.cgImage!, in: imageRect)
        let imageRef: CGImage = context!.makeImage()!
        return imageRef
    }
    
    func crop(into boundingBox: CGRect) -> UIImage? {
        guard let drawnImage = self.cgImage?.cropping(to: boundingBox) else {return nil}
        let croppedImage = UIImage(cgImage: drawnImage)
        return croppedImage
    }
}
