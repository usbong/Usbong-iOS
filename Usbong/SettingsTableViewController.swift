//
//  SettingsTableViewController.swift
//  Usbong
//
//  Created by Joe Amanse on 13/03/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    lazy var indexPathForVersionCell: NSIndexPath = {
        let lastSection = self.tableView.numberOfSections - 1
        let lastRow = self.tableView.numberOfRowsInSection(lastSection) - 1
        
        return NSIndexPath(forRow: lastRow, inSection: lastSection)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath == indexPathForVersionCell {
            cell.detailTextLabel?.text = UIApplication.appVersion
        }
    }
}
