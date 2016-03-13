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
    var treeURLs: [NSURL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Reload tree list
        reloadTreeList()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Reload tree list every time view appears
        
        reloadTreeList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadTreeList() {
        // Fetch tree urls
        treeURLs = UsbongFileManager.defaultManager().treesAtRootURL()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return treeURLs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("treeCell", forIndexPath: indexPath)
        
        // Set text of cell to file name without extension
        var fileName = treeURLs[indexPath.row].URLByDeletingPathExtension?.lastPathComponent
        
        // If all spaces or doesn't exist, resort to default file name
        if fileName?.stringByReplacingOccurrencesOfString(" ", withString: "").characters.count == 0 || fileName == nil {
            fileName = UsbongFileManager.defaultManager().defaultFileName
        }
        
        // Configure the cell...
        cell.textLabel?.text = fileName
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
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
                treeVC.treeURL = treeURLs[indexPath.row]
            }
        }
    }
}
