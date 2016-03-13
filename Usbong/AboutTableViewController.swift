//
//  AboutTableViewController.swift
//  Usbong
//
//  Created by Joe Amanse on 13/03/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// - returns: URL for `title` and `detail`
    func urlForTitle(title: String, andDetail detail: String) -> NSURL? {
        let urlString: String
        
        switch (title, detail) {
        case ("Website", let detail):
            urlString = "http://\(detail)"
        case ("Mailing List", let detail):
            urlString = "mailto://\(detail)"
        case ("Email", let detail):
            urlString = "mailto://\(detail)"
        default:
            return nil
        }
        
        return NSURL(string: urlString)
    }
    
    /// - returns: URL for `cell`
    func urlForCell(cell: UITableViewCell) -> NSURL? {
        guard let title = cell.textLabel?.text else { return nil }
        guard let detail = cell.detailTextLabel?.text else { return nil }
        
        return urlForTitle(title, andDetail: detail)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        guard let url = urlForCell(cell) else { return }
        
        UIApplication.sharedApplication().openURL(url)
    }
}
