//
//  SetupShareButton.swift
//  canvasDrawingApp
//
//  Created by Pranav Paul on 31/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import UIKit
import MultipeerConnectivity

extension ViewController: MCSessionDelegate, MCNearbyServiceAdvertiserDelegate {

    func setupOpenOnMacButton() {
        let openOnMacButton: UIButton = UIButton(frame: CGRect(x: 45, y: 28, width: 88, height: 88))
        openOnMacButton.setImage(UIImage(named: "open_on_mac_button"), for: .normal)
        openOnMacButton.layer.shadowPath = UIBezierPath(rect: openOnMacButton.bounds).cgPath
        openOnMacButton.layer.shadowRadius = 50
        openOnMacButton.layer.shadowOffset = .zero
        openOnMacButton.layer.shadowOpacity = 0.9
        openOnMacButton.showsTouchWhenHighlighted = true
        view.addSubview(openOnMacButton)
        openOnMacButton.addTarget(self, action: #selector(openOnMac), for: .touchUpInside)
       
        let openOnMacLabel: UILabel = UILabel(frame: CGRect(x: 35, y: 125, width: 120, height: 31))
        openOnMacLabel.text = "Send to mac"
        openOnMacLabel.textAlignment = .center
        openOnMacLabel.backgroundColor = .white
        openOnMacLabel.textColor = UIColor.link
        openOnMacLabel.layer.cornerRadius = 5
        openOnMacLabel.clipsToBounds = true
        view.addSubview(openOnMacLabel)
    }
    
    @objc func openOnMac() {
        var data: [DataToSend] = []
        getDataToSend(data: &data)
        
        // convert to JSON
        do {
            let jsonData = try JSONEncoder().encode(data)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            dataStringToSend = jsonString
            print(dataStringToSend)
        } catch {
            print("couldn't encode the data")
        }
        // setup session
        setupSession()
    }
  
    func getDataToSend(data: inout [DataToSend]) {
        
        print(finalElementPositions)
        
        for element in finalElementPositions {
            
            // labels
            if let element = (element as? LabelInfo) {
                let frame = element.elementBoundingBox
                let text = element.text
                if text.count == 0 {break} // empty string
                guard let type = element.labelType else {break}
                switch type {
                case .title:
                    data.append(DataToSend(frame: frame, text: text, attributedText: "title"))
                    break
                case .subtitle:
                    data.append(DataToSend(frame: frame, text: text, attributedText: "subtitle"))
                    break
                case .imageBannerViewLabel:
                    data.append(DataToSend(frame: frame, text: text, attributedText: "imageBannerViewLabel"))
                    break
                case .body:
                    data.append(DataToSend(frame: frame, text: text, attributedText: "body"))
                    break
                case .buttonDescriptor:
                    data.append(DataToSend(frame: frame, text: text, attributedText: "buttonDescriptor"))
                }
            }
            
            // non-Labels
            if let element = (element as? DrawingInfo) {
                let frame = element.elementBoundingBox
                var image: UIImage?
                
                // buttons
                if let symbol = element.data as? SymbolType {
                    switch symbol {
                    case .magnifying_glass:
                        image = UIImage(named: "Magnifying_glass")
                        break
                    case .profile:
                        image = UIImage(named: "Profile_icon")
                        break
                    case .location:
                        image = UIImage(named: "Location")
                        break
                    }
                    guard let unwrappedImage = image else {break}
                    
                    var dataInstance = DataToSend(frame: frame)
                    dataInstance.buttonImage = unwrappedImage.jpegData(compressionQuality: 1.0)?.base64EncodedString()
                    data.append(dataInstance)
                }
                
                // imageViews done outside - since we want to access the actual image
            }
        }
        
        // for imageViews - want to access the actual image
        for subview in generatedBackgroundView.subviews {
            if let imageView = (subview as? UIImageView) {
                let frame = imageView.frame
                let image = imageView.image
                guard let unwrappedImage = image else {break}
                let accessibilityLabel = imageView.accessibilityLabel
                
                var dataInstance = DataToSend(frame: frame)
                dataInstance.image = unwrappedImage.jpegData(compressionQuality: 1.0)?.base64EncodedString()
                dataInstance.accessibilityLabel = accessibilityLabel
                data.append(dataInstance)
            }
            
            // MARK: suggested labels - append to 'finalElementPositions' when added to bgGeneratedView
            
        }
        
    }
    
    func setupSession() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "subviews")
        mcAdvertiserAssistant.delegate = self
        mcAdvertiserAssistant.startAdvertisingPeer()
    }
    
    
    // MARK: Methods for MCNearbyServiceAdvertiserDelegate
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("received invitation")
        invitationHandler(true, mcSession)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        if state == .connected {
            if self.mcSession.connectedPeers.count <= 0 {
                return
            }
            do {
                try self.mcSession.send(dataStringToSend.data(using: .utf8)!, toPeers: self.mcSession.connectedPeers, with: .reliable)
            } catch {
                print("couldn't send data")
            }
        }
    }
    
   func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        print("Connecting")
        certificateHandler(true)
    }
}
