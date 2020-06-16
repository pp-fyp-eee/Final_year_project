//
//  PopoverController.swift
//  customPopoverImageCollectionView
//
//  Created by Pranav Paul on 04/06/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit
import Photos

// avoids use of global variables
protocol PopoverDelegate {
    var selectedIndex: Int {get set}
    var didSelectImageFromLibrary: Bool {get set}
    var selectedImage: UIImage? {get set}
    func popoverDismissed()
}

class PopoverImageCollectionContentController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var delegate: PopoverDelegate?
    var images: [UIImage] = []
    
    // for custom image from user's library
    var imagePicker = UIImagePickerController()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        // reset in-case user selected own image and now wants to change to a downloaded image
        delegate?.didSelectImageFromLibrary = false
        delegate?.selectedIndex = indexPath.row
        dismiss(animated: true, completion: nil)
        delegate?.popoverDismissed()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            setupHeaderView(supplementaryView: view)
            return view
        }
        fatalError("Couldn't bind to collectionView")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    func setupHeaderView(supplementaryView: UIView) {
        
        // if ImageView
        let titleLabel: UILabel = UILabel(frame: CGRect(x: 16, y: 23, width: 229, height: 40))
        let formatting = Constants.TextFormatting.getSubTitleFormatting()
        titleLabel.attributedText = NSAttributedString(string: ImageViewPopoverData.getTitle(), attributes: formatting)
        supplementaryView.addSubview(titleLabel)
        
        let description: UILabel = UILabel(frame: CGRect(x: 16, y: 72, width: 218, height: 67))
        description.text = ImageViewPopoverData.getDescription()
        description.font = UIFont.systemFont(ofSize: 17)
        description.numberOfLines = 3
        supplementaryView.addSubview(description)
        
        let viewGuidelinesButton: UIButton = UIButton(type: .custom) as UIButton
        viewGuidelinesButton.frame = CGRect(x: 16, y: 156, width: 221, height: 25)
        viewGuidelinesButton.setTitle(" View guidelines", for: .normal)
        viewGuidelinesButton.setImage(UIImage(systemName: "safari"), for: .normal)
        viewGuidelinesButton.setTitleColor(.link, for: .normal)
        viewGuidelinesButton.contentHorizontalAlignment = .left
        viewGuidelinesButton.showsTouchWhenHighlighted = true
        viewGuidelinesButton.addTarget(self, action: #selector(openHumanInterfaceGuidelines(sender:)), for: .touchUpInside)
        supplementaryView.addSubview(viewGuidelinesButton)
        
        let dividerLine: UIView = UIView(frame: CGRect(x: 16, y: 195, width: 221, height: 1))
        dividerLine.backgroundColor = UIColor.separator
        supplementaryView.addSubview(dividerLine)
        
        let pickOwnImageButton: UIButton = UIButton(type: .custom) as UIButton
        pickOwnImageButton.frame = CGRect(x: 16, y: 209, width: 221, height: 25)
        pickOwnImageButton.setTitle(" Your photo gallery", for: .normal)
        pickOwnImageButton.setImage(UIImage(systemName: "photo"), for: .normal)
        pickOwnImageButton.setTitleColor(.link, for: .normal)
        pickOwnImageButton.contentHorizontalAlignment = .left
        pickOwnImageButton.showsTouchWhenHighlighted = true
        pickOwnImageButton.addTarget(self, action: #selector(openImagePickerController(sender:)), for: .touchUpInside)
        supplementaryView.addSubview(pickOwnImageButton)
        
        let secondDividerLine: UIView = UIView(frame: CGRect(x: 16, y: pickOwnImageButton.frame.maxY + 14, width: 221, height: 1))
        secondDividerLine.backgroundColor = UIColor.separator
        supplementaryView.addSubview(secondDividerLine)
        
        let similarImagesLabel: UILabel = UILabel(frame: CGRect(x: 16, y: secondDividerLine.frame.maxY + 14, width: 166, height: 30))
        similarImagesLabel.text = "Similar images"
        similarImagesLabel.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        supplementaryView.addSubview(similarImagesLabel)
        
    }
    
    @objc func openHumanInterfaceGuidelines(sender: UIButton!) {
        guard let url = ImageViewPopoverData.getDocumentationUrl() else {return}
        UIApplication.shared.open(url)
    }

}

// extension with UIImagePickerControllerDelegate delegate
extension PopoverImageCollectionContentController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func openImagePickerController(sender: UIButton!) {
            
        // request authorisation
        PHPhotoLibrary.requestAuthorization({_ in })
        
        // authorisation granted
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImageFromLibrary = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        picker.dismiss(animated: true, completion: nil)
        delegate?.didSelectImageFromLibrary = true
        delegate?.selectedImage = selectedImageFromLibrary
     
        // dismiss the overallPopOver
        dismiss(animated: true, completion: nil)
        delegate?.popoverDismissed()
    }
}





struct ImageViewPopoverData {
    static func getTitle() -> String {
        return "UIImageView"
    }
    static func getDescription() -> String {
        return "UIImageView is a subclass of UIView, that contains image data."
    }
    static func getDocumentationUrl() -> URL? {
        return URL(string: "https://developer.apple.com/design/human-interface-guidelines/ios/views/image-views/")
    }
}
