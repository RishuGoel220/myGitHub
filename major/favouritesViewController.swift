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
        // Fetch Data using Api call for repos
        
        displayData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        displayData()
    }
    
    
    
    
    func displayData(){
        dispatch_async(dispatch_get_main_queue(), {
            let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            //2
            let fetchRequest = NSFetchRequest(entityName: "Repositories")
            fetchRequest.predicate = NSPredicate(format: "isFavourite == %@ and users CONTAINS %@", "true", RepositoryViewController().currentUser())
            //3
            do {
                let results =
                    try managedContext.executeFetchRequest(fetchRequest)
                self.repositories = results as! [NSManagedObject]
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            
        })
    }

    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        // Set the first row text label to the firstRowLabel data in our current array item
        dispatch_async(dispatch_get_main_queue(), {
            
            
            cell.favouriteRepoName.text = self.repositories[indexPath.row].valueForKey("repositoryName") as? String
            
        })
        // Return our new cell for display
        return cell

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "favContributorSegue"
        {
            let destination = segue.destinationViewController as? contributorViewController,
            repositoryIndex = tableView.indexPathForSelectedRow?.row
            destination!.repository  = (self.repositories[repositoryIndex!].valueForKey("repositoryName") as? String)!
        }
    }
}