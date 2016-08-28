//
//  UtilityHandler.swift
//  major
//
//  Created by Rishu Goel on 25/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import Foundation
import UIKit


class UtilityHandler{
    
    func showAlertWithSingleButton(title: String, message: String)-> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel , handler: nil))
        return alert
    }
    func valueForAPI(named keyname:String) -> String {
        let filePath = NSBundle.mainBundle().pathForResource("APIkeys", ofType: "plist")
        let plist = NSDictionary(contentsOfFile:filePath!)
        let value = plist?.objectForKey(keyname) as! String
        return value
    }

}
