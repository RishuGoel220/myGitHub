//
//  favouritesViewController.swift
//  major
//
//  Created by Rishu Goel on 16/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit
import CoreData
class favouritesViewController: UITableViewController {
    
    var repositories = [NSManagedObject] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayData()  
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
         displayData()
    }

    
    func displayData(){
        self.repositories = DatabaseHandler().fetchFavouriteRepositories()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
        
    }
    
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let message = "Description : \(self.repositories[indexPath.row].valueForKey("descriptionRepo") as! String)"
        let alert = UIAlertView(title: "\(self.repositories[indexPath.row].valueForKey("repositoryName") as! String) ", message: message, delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favouritePrototype") as! favouriteCells
        dispatch_async(dispatch_get_main_queue(), {
            cell.favouriteRepoName.text = self.repositories[indexPath.row].valueForKey("repositoryName") as? String
        })
        return cell

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "RepositoryDescriptionScreen"
        {
            let destination = segue.destinationViewController as? RepositoryDetailsController,
            repositoryIndex = tableView.indexPathForSelectedRow?.row
            destination!.repositoryName  = (self.repositories[repositoryIndex!].valueForKey("repositoryName") as? String)!
        }
    }
}