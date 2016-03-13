//
//  LicensesData.swift
//  Usbong
//
//  Created by Joe Amanse on 13/03/2016.
//  Copyright © 2016 Usbong Social Systems, Inc. All rights reserved.
//

import Foundation

struct LicensesData {
    static func licenseTextForLicense(license: String) -> String? {
        guard let url = NSBundle.mainBundle().URLForResource(license, withExtension: "license") else { return nil }
        return try? String(contentsOfURL: url)
    }
}
