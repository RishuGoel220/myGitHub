//
//  RepositoryViewController.swift
//  major
//
//  Created by Rishu Goel on 16/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit

class RepositoryViewController: UITableViewController {
    struct MyData {
        var repositoryNameLabel:String
    }
    
    var tableData: [MyData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetch Data using Api call for repos
        tableData = [
            MyData(repositoryNameLabel: "The first row"),
            MyData(repositoryNameLabel: "The second row"),
            MyData(repositoryNameLabel: "Third and final row")
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cellPrototype") as! repositoryCells
        // Set the first row text label to the firstRowLabel data in our current array item
        dispatch_async(dispatch_get_main_queue(), {
            
            
            cell.repositoryName.text = self.tableData[indexPath.row].repositoryNameLabel
            
        })
        // Return our new cell for display
        return cell
        
    }

}
