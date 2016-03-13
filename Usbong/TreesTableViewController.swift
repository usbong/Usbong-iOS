//
//  TreesTableViewController.swift
//  Usbong
//
//  Created by Chris Amanse on 12/15/15.
//  Copyright © 2015 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit
import UsbongKit

class TreesTableViewController: UITableViewController {
    var sampleTreeURLs: [NSURL] = []
    var treeURLs: [NSURL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Reload tree list
        reloadTreeList()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didOpenURL:"), name: UsbongNotification.CopiedTreeInApp, object: nil)
        
        // Reload tree list every time view appears
        reloadTreeList()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadTreeList() {
        // Fetch tree urls
        sampleTreeURLs = NSBundle.mainBundle().URLsForResourcesWithExtension("utree", subdirectory: nil) ?? []
        treeURLs = UsbongFileManager.defaultManager().treesAtRootURL()
        tableView.reloadData()
    }
    
    func didOpenURL(notification: NSNotification) {
        reloadTreeList()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if sampleTreeURLs.count == 0 {
            return 1
        }
        
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sampleTreeURLs.count > 0 && section == 0 {
            return 1
        }
        
        return treeURLs.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if sampleTreeURLs.count > 0 && section == 0 {
            return "Samples"
        }
        
        return "Documents"
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if sampleTreeURLs.count > 0 && section == 0 {
            return nil
        }
        
        return "To add more trees in Documents, add .utree files by using iTunes File Sharing or by opening them from other apps using the \"Open In...\" Share Dialog, and choosing \"Copy to Usbong\"."
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("treeCell", forIndexPath: indexPath)
        
        // Get url
        let url: NSURL
        if sampleTreeURLs.count > 0 && indexPath.section == 0 {
            url = sampleTreeURLs[indexPath.row]
        } else {
            url = treeURLs[indexPath.row]
        }
        
        // Set text of cell to file name without extension
        var fileName = url.URLByDeletingPathExtension?.lastPathComponent
        
        // If all spaces or doesn't exist, resort to default file name
        if fileName?.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count == 0 || fileName == nil {
            fileName = UsbongFileManager.defaultManager().defaultFileName
        }
        
        // Configure the cell...
        cell.textLabel?.text = fileName
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Do not allow editing on sample trees
        if sampleTreeURLs.count > 0 && indexPath.section == 0 {
            return false
        }
        
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Get index and URL
            let index = indexPath.row
            let fileToDeleteURL = treeURLs[index]
            do {
                // Attempt to delete file
                try NSFileManager.defaultManager().removeItemAtURL(fileToDeleteURL)
                
                // If delete successful, remove URL from data source
                treeURLs.removeAtIndex(index)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            } catch let error {
                print("Failed to delete. Error:\n\(error)")
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "presentTree" {
            if let treeVC = (segue.destinationViewController as? UINavigationController)?.topViewController as? TreeViewController, let indexPath = tableView.indexPathForSelectedRow {
                let treeURL: NSURL
                if sampleTreeURLs.count > 0 && indexPath.section == 0 {
                    treeURL = sampleTreeURLs[indexPath.row]
                } else {
                    treeURL = treeURLs[indexPath.row]
                }
                
                treeVC.treeURL = treeURL
            }
        }
    }
}
