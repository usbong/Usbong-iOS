//
//  TreeViewController.swift
//  The Chocolate Project
//
//  Created by Chris Amanse on 12/13/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import UsbongKit

private enum TransitionDirection {
    case Backward, Forward
}

class TreeViewController: UIViewController, PlayableTree, HintsTextViewDelegate {
    
    @IBOutlet weak var buttonsContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var nodeView: NodeView!
    
    var tree: UsbongTree?
    var treeURL: NSURL?
    
    lazy var speechSynthesizer = AVSpeechSynthesizer()
    var backgroundAudioPlayer: AVAudioPlayer?
    var voiceOverAudioPlayer: AVAudioPlayer?
    
    var voiceOverOn: Bool {
        get {
            // Default to true if not yet set
            let standardUserDefaults = NSUserDefaults.standardUserDefaults()
            if standardUserDefaults.objectForKey("SpeechOn") == nil {
                standardUserDefaults.setBool(true, forKey: "SpeechOn")
            }
            return standardUserDefaults.boolForKey("SpeechOn")
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: "SpeechOn")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) { () -> Void in
            var tree: UsbongTree? = nil
            var title: String? = nil
            
            if let treeURL = self.treeURL {
                if let treeRootURL = UsbongFileManager.defaultManager().unpackTreeToCacheDirectoryWithTreeURL(treeURL) {
                    tree = UsbongTree(treeRootURL: treeRootURL)
                    
                    title = tree?.title
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tree = tree
                self.navigationItem.title = title ?? "Unknown"
                
                self.reloadNode()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        let oldInsets = nodeView.tableView.contentInset
        nodeView.tableView.contentInset = UIEdgeInsets(top: oldInsets.top, left: oldInsets.left, bottom: buttonsContainerViewHeightConstraint.constant, right: oldInsets.right)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        stopVoiceOver()
        
        // Print output
        let output: String = tree?.generateOutput(UsbongAnswersGeneratorDefaultCSVString.self) ?? ""
        print("Output: \(output)")
        
        // Save csv on exit
        tree?.saveOutputData(UsbongAnswersGeneratorDefaultCSVString.self) { (success, filePath) in
            print("Answers saved to \(filePath): \(success)")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func didPressExit(sender: AnyObject) {
        print("Did Press Exit")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressMore(sender: AnyObject) {
        showAvailableActions(sender)
    }
    
    @IBAction func didPressPrevious(sender: AnyObject) {
        transitionToPreviousNode()
    }
    
    @IBAction func didPressNext(sender: AnyObject) {
        transitionToNextNode()
    }
}
