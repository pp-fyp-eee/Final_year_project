//
//  ViewController.swift
//  ReceiveDataFromiPad
//
//  Created by Pranav Paul on 29/05/2020.
//  Copyright © 2020 Pranav Paul. All rights reserved.
//

import Cocoa
import MultipeerConnectivity

struct Constants {
    struct TextFormatting {
        static func getTitleFormatting() -> String {
            return "[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 45, weight: .bold)] as [NSAttributedString.Key : Any]"
        }
        static func getSubTitleFormatting() -> String {
            return "[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 35, weight: .bold)] as [NSAttributedString.Key : Any]"
        }
        static func getImageBannerViewTextFormatting() -> String {
            return "[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor.white] as [NSAttributedString.Key : Any]"
        }
        static func getBodyFormatting() -> String {
            return "[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .semibold)] as [NSAttributedString.Key : Any]"
        }
        static func getButtonLabelFormatting() -> String {
            return "[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .semibold), NSAttributedString.Key.foregroundColor: Constants.Colors.buttonBlue] as [NSAttributedString.Key : Any]"
        }
    }
}

extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
}

struct ReceivedData: Codable {
    var frame: CGRect
    
    // for labels
    var text: String?
    var attributedText: String?
    
    // for buttons
    var buttonImage: String?
    
    // for imageViews
    var image: String?
    var accessibilityLabel: String?
    
}

class ViewController: NSViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceBrowserDelegate {
    
    var codeToInsert: String = ""
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("found peer")
        let data = "Does this work?"
        mcBrowser.invitePeer(peerID, to: mcSession, withContext: data.data(using: .utf8)!, timeout: TimeInterval(2000))
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lost peer")
    }
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcBrowser: MCNearbyServiceBrowser!

    override func viewDidLoad() {
        super.viewDidLoad()
        peerID = MCPeerID(displayName: Host.current().name ?? "Mac")
        // MARK: change to .none for encryption
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        
        mcBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: "subviews")
        mcBrowser.delegate = self
        mcBrowser.startBrowsingForPeers()
    }

    @IBAction func buttonDidClick(_ sender: Any) {
        return
    }
    

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print(state)
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("getting data")
        do {
            print("Received")
            
            let data = try JSONDecoder().decode([ReceivedData].self, from: data)
            print(data)
            session.disconnect()
            initialiseCodeString()
            codeToInsert += createCodeString(data: data)
            finaliseCodeString()
            
            let desktopPath = (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first! + "/ViewController.swift"
            
            let filename = URL(fileURLWithPath: desktopPath)
            
            print(filename)
            do {
                try codeToInsert.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            } catch {
                // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                print("couldn't save")
            }
            
        } catch {
            print("whoops")
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("received stream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("did start receiving resource")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("did finish receiving resource")
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        print("cancelled")
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        print("cancelled")
    }
    
    
    
    func initialiseCodeString() {
        codeToInsert += """
//
//  ViewController.swift
//
//  Created using Design Studio ⓡ on \(Date())
//

import UIKit

class ViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        
"""
    }
    
    func finaliseCodeString() {
        codeToInsert += """

    }
        
}
"""
    }
    
    
    
    func createCodeString(data: [ReceivedData]) -> String {
        var code: String = ""
        
        for (index, element) in data.enumerated() {
            
            let x = element.frame.minX
            let y = element.frame.minY
            let width = element.frame.width
            let height = element.frame.height
            
            // label
            if element.text != nil || element.attributedText != nil {
                code += "let label\(index) = UILabel(frame: CGRect(x: \(x), y: \(y), width: \(width), height: \(height)))\n"
                code += "label\(index).attributedText = NSAttributedString(string: \"\(element.text!.firstUppercased)\", attributes:"
                print(element.attributedText!)
                if element.attributedText == "title" {
                    code += Constants.TextFormatting.getTitleFormatting()
                }
                else if element.attributedText == "subtitle" {
                    code += Constants.TextFormatting.getSubTitleFormatting()
                }
                else if element.attributedText == "imageBannerViewLabel" {
                    code += Constants.TextFormatting.getImageBannerViewTextFormatting()
                }
                else if element.attributedText == "buttonDescriptor" {
                    code += Constants.TextFormatting.getButtonLabelFormatting()
                }
                else {
                    // body
                    code += Constants.TextFormatting.getBodyFormatting()
                }
                code += ")"
                code += "\nview.addSubview(label\(index))\n\n"
            }
            
            // button
            else if element.buttonImage != nil {
                code += "let button\(index) = UIButton(type: .custom)\n"
                code += "button\(index).frame = CGRect(x: \(x-20), y: \(y+30), width: \(width), height: \(height))\n"
                code += "let imageForButton\(index)Data = Data.init(base64Encoded: \"\(element.buttonImage!)\", options: .init(rawValue: 0))\n"
                code += "let imageForButton\(index) = UIImage(data: imageForButton\(index)Data!)\n"
                code += "button\(index).setImage(imageForButton\(index), for: .normal)\n"
                code += "\nview.addSubview(button\(index))\n\n"
            }
            
            // imageViews
            else if element.accessibilityLabel != nil {
                code += "let imageView\(index) = UIImageView(frame: CGRect(x: \(x), y: \(y), width: \(width), height: \(height)))\n"
                code += "let imageForImageView\(index)Data = Data.init(base64Encoded: \"\(element.image!)\", options: .init(rawValue: 0))\n"
                code += "let imageForImageView\(index) = UIImage(data: imageForImageView\(index)Data!)\n"
                code += "imageView\(index).image = imageForImageView\(index)\n"
                code += "imageView\(index).accessibilityLabel = \"\(element.accessibilityLabel ?? "image")\"\n"
                code += "imageView\(index).isAccessibilityElement = true\n"
                code += "\nview.addSubview(button\(index))\n\n"
            }

        }
        
        return code
    }

}
