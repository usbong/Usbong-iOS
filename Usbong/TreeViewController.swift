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

class TreeViewController: UIViewController {
    
    @IBOutlet weak var buttonsContainerViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var taskNodeView: TaskNodeView!
    
    var tree: UsbongTree?
    var treeURL: NSURL?
    
    lazy var speechSynthezier: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var backgroundAudioPlayer: AVAudioPlayer?
    var audioSpeechPlayer: AVAudioPlayer?
    
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
                
                self.reloadCurrentTaskNode()
                
                // Set hints text view delegate in task node view
                self.taskNodeView.hintsTextViewDelegate = self
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        let oldInsets = taskNodeView.taskNodeTableView.contentInset
//        let topInset: CGFloat
//        if let navBar = navigationController?.navigationBar {
//            let statusBar: CGFloat
//            if view.
//            
//            topInset = navBar.frame.height
//        } else {
//            topInset = oldInsets.top
//        }
        taskNodeView.taskNodeTableView.contentInset = UIEdgeInsets(top: oldInsets.top, left: oldInsets.left, bottom: buttonsContainerViewHeightConstraint.constant, right: oldInsets.right)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func didPressExit(sender: AnyObject) {
        print("Did Press Exit")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didPressMore(sender: AnyObject) {
        print("Did Press More")
        
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let onOrOffText = voiceOverOn ? "Off" : "On"
        let speechAction = UIAlertAction(title: "Speech \(onOrOffText)", style: .Default) { (action) -> Void in
            let turnOn = !self.voiceOverOn
            
            // If toggled to on, start voice-over
            if turnOn {
                self.startVoiceOver()
            } else {
                self.stopVoiceOver()
            }
            
            self.voiceOverOn = turnOn
        }
        let setLanguageAction = UIAlertAction(title: "Set Language", style: .Default) { (action) -> Void in
            self.showChoosLanguageScreen()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionController.addAction(speechAction)
        actionController.addAction(setLanguageAction)
        actionController.addAction(cancelAction)
        
        // For iPad action sheet behavior (similar to a popover)
        if let popover = actionController.popoverPresentationController, let barButtonItem = sender as? UIBarButtonItem {
            popover.barButtonItem = barButtonItem
        }
        
        presentViewController(actionController, animated: true, completion: nil)
    }
    
    @IBAction func didPressPrevious(sender: AnyObject) {
        print("Did Press Previous")
        
        transitionWithDirection(.Backward)
    }
    
    @IBAction func didPressNext(sender: AnyObject) {
        print("Did Press Next")
        
        transitionWithDirection(.Forward)
    }
    
    // MARK: - Custom
    
    // MARK: Transition
    private func reloadCurrentTaskNode() {
        if let currentTaskNode = tree?.currentTaskNode {
            taskNodeView.taskNode = currentTaskNode
            
            // Background image
            if let backgroundImageFilePath = currentTaskNode.backgroundImageFilePath {
                taskNodeView.backgroundImageView.image = UIImage(contentsOfFile: backgroundImageFilePath)
            }
            
            // Hints dictionary
            if let hintsDictionary = tree?.hintsDictionary {
                print(hintsDictionary)
                taskNodeView.hintsDictionary = hintsDictionary
            }
            
            // Background audio - change only if not empty and different
            if let taskNodeBGFilePath = currentTaskNode.backgroundAudioFilePath {
                let currentBGFilePath = backgroundAudioPlayer?.url?.path ?? ""
                if taskNodeBGFilePath.characters.count > 0 && taskNodeBGFilePath != currentBGFilePath {
                    backgroundAudioPlayer = nil
                    
                    loadBackgroundAudio()
                }
            }
            
            // Start voice-over if on
            if voiceOverOn {
                startVoiceOver()
            }
        }
    }
    
    private func transitionWithDirection(direction: TransitionDirection) {
        if let loadedTree = tree {
            // Before transition
            stopVoiceOver()
            
            if direction == .Backward {
                // Previous
                if !loadedTree.previousTaskNodeIsAvailable {
                    dismissViewControllerAnimated(true, completion: nil)
                    return
                } else {
                    loadedTree.transitionToPreviousTaskNode()
                }
                
            } else {
                // Next transition
                if loadedTree.currentTaskNode is EndStateTaskNode || !loadedTree.nextTaskNodeIsAvailable {
                    dismissViewControllerAnimated(true, completion: nil)
                    return
                } else {
                    loadedTree.transitionToNextTaskNode()
                }
            }
            
            reloadCurrentTaskNode()
            
            // Finished transition
            // Change back button title to exit if there are no previous task nodes
            if !loadedTree.previousTaskNodeIsAvailable {
                previousButton.setTitle("EXIT", forState: .Normal)
            } else {
                previousButton.setTitle("BACK", forState: .Normal)
            }
            
            // Change next button title to exit if transitioned node is end state
            if loadedTree.currentTaskNode is EndStateTaskNode || !loadedTree.nextTaskNodeIsAvailable {
                nextButton.setTitle("EXIT", forState: .Normal)
            } else {
                nextButton.setTitle("NEXT", forState: .Normal)
            }
        }
    }
    
    // MARK: Background audio
    
    func loadBackgroundAudio() {
        if let currentTaskNode = tree?.currentTaskNode {
            if let backgroundAudopFilePath = currentTaskNode.backgroundAudioFilePath {
                if let audioPlayer = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: backgroundAudopFilePath)) {
                    audioPlayer.numberOfLoops = -1 // Endless loop
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                    audioPlayer.volume = 0.4
                    
                    backgroundAudioPlayer = audioPlayer
                }
            }
        }
    }
    
    // MARK: Voice-over
    func startVoiceOver() {
        if let currentTaskNode = tree?.currentTaskNode {
            // Attempt to play speech from audio file, if failed, resort to text-to-speech
            if !startAudioSpeechInTaskNode(currentTaskNode) {
                print(">>> Text-to-speech")
                startTextToSpeechInTaskNode(currentTaskNode)
            }
        }
    }
    func stopVoiceOver() {
        stopTextToSpeech()
        stopAudioSpeech()
    }
    
    func startTextToSpeechInTaskNode(taskNode: TaskNode) {
        let modules = taskNode.modules
        for module in modules {
            if let textModule = module as? TextTaskNodeModule {
                print("\(textModule.text)")
                let utterance = AVSpeechUtterance(string: textModule.text)
                
                utterance.voice = AVSpeechSynthesisVoice(language: tree?.currentLanguageCode ?? "en-EN")
                
                // Speak
                speechSynthezier.speakUtterance(utterance)
            }
        }
    }
    func stopTextToSpeech() {
        if speechSynthezier.speaking {
            speechSynthezier.stopSpeakingAtBoundary(.Immediate)
        }
    }
    
    func startAudioSpeechInTaskNode(taskNode: TaskNode) -> Bool {
        if let audioFilePath = taskNode.audioFilePath {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: audioFilePath))
                
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
                audioSpeechPlayer = audioPlayer
                print(">>> Played Audio File")
                return true
            } catch let error as NSError {
                print("Error loading audio file: \(error)")
                return false
            }
        }
        return false
    }
    func stopAudioSpeech() {
        if let player = audioSpeechPlayer {
            if player.playing {
                player.stop()
            }
        }
    }
    
    // MARK: Translation
    
    func showChoosLanguageScreen() {
        print(">>> Show choose language screen")
        
        // Create languages view controller
        let languagesVC = LanguagesTableViewController()
        languagesVC.tree = tree
        languagesVC.selectLanguageCompletion = {
            self.reloadCurrentTaskNode()
        }
        
        // Embed in navigation controller
        let navigationController = UINavigationController(rootViewController: languagesVC)
        
        presentViewController(navigationController, animated: true, completion: nil)
    }
}

extension TreeViewController: HintsTextViewDelegate {
    func hintsTextView(textView: HintsTextView, didTapString: String, withHint hint: String) {
        let alertController = UIAlertController(title: "Word Hint", message: hint, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        alertController.addAction(okAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}