//
//  ContributorViewController.swift
//  major
//
//  Created by Rishu Goel on 16/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit

class ContributorViewController: UITableViewController {
    struct MyData {
        var contributorNameLabel:String
        var linesAddedLabel:String
        var linesDeletedLabel:String
    }
    
    var tableData: [MyData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetch Data using Api call for contributors to a repo
        tableData = [
            MyData(contributorNameLabel: "The first row",linesAddedLabel: "35",linesDeletedLabel: "45"),
            MyData(contributorNameLabel: "second row",linesAddedLabel: "35",linesDeletedLabel: "45"),
            MyData(contributorNameLabel: "Third row",linesAddedLabel: "35",linesDeletedLabel: "45")
        ]
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contributorPrototype") as! contributorCells
        // Set the first row text label to the firstRowLabel data in our current array item
        dispatch_async(dispatch_get_main_queue(), {
            
            
            cell.contributorsName.text = self.tableData[indexPath.row].contributorNameLabel
            cell.linesAdded.text = self.tableData[indexPath.row].linesAddedLabel
            cell.linesDeleted.text = self.tableData[indexPath.row].linesDeletedLabel
            
            
        })
        // Return our new cell for display
        return cell
        
    }

}
