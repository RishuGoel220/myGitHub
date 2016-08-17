//
//  RepositoryViewController.swift
//  major
//
//  Created by Rishu Goel on 16/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class RepositoryViewController: UITableViewController {
    
    var repositories = [NSManagedObject]()
    
    @IBAction func favButtonClicked(sender: AnyObject) {
        print(sender.tag)
        var appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        var context: NSManagedObjectContext = appDel.managedObjectContext
        
        var fetchRequest = NSFetchRequest(entityName: "Repositories")
        fetchRequest.predicate = NSPredicate(format: "repositoryName = %@", (self.repositories[sender.tag].valueForKey("repositoryName") as? String)!)
        
        
        do {
            let fetchResults =
                try appDel.managedObjectContext.executeFetchRequest(fetchRequest)
                if fetchResults.count != 0{
    
                    var managedObject = fetchResults[0]
                    managedObject.setValue(true, forKey: "isFavourite")
    
                    try context.save()
                }

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if Reachability.isConnectedToNetwork() == true {
            getRepositories()
        } else {
            displayData()
        }
        
    }
    
    
    
    
    func getRepositories(){
        Alamofire.request(.GET, "https://api.github.com/orgs/practo/repos", parameters: [:])
            .responseJSON { response in
                let json = JSON(response.result.value!)
                
                for item in json.arrayValue {
                    var name = item["name"].stringValue
                    let appDelegate =
                        UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext
                    
                    
                    var fetchRequest = NSFetchRequest(entityName: "Repositories")
                    fetchRequest.predicate = NSPredicate(format: "repositoryName = %@", name)
                    
                    
                    do {
                        let fetchResults =
                            try managedContext.executeFetchRequest(fetchRequest)
                        if fetchResults.count != 0{
                            print (name)
                            continue
                        }
                        
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                    }
                    print(name+"hi")
                    
                    
                    
                    
                    
                    
                    
                    
                    //2
                    let entity =  NSEntityDescription.entityForName("Repositories",
                        inManagedObjectContext:managedContext)
                    
                    let repo = NSManagedObject(entity: entity!,
                        insertIntoManagedObjectContext: managedContext)
                    
                    //3
                    repo.setValue(name, forKey: "repositoryName")
                    repo.setValue(false, forKey: "isFavourite")
                    
                    //4
                    do {
                        try managedContext.save()
                        self.repositories.append(repo)
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                    
                }
               self.displayData()
            
        }
    }
    
    
    func displayData(){
        dispatch_async(dispatch_get_main_queue(), {
            let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            //2
            let fetchRequest = NSFetchRequest(entityName: "Repositories")
            
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
    
    func deleteAllData(entity: String)
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext.deleteObject(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
        
    }
    
    
    
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellPrototype") as! repositoryCells
        // Set the first row text label to the firstRowLabel data in our current array item
        cell.favButton.tag = indexPath.row
        cell.favButton.addTarget(self, action: #selector(favButtonClicked(_:)), forControlEvents: .TouchUpInside)
        dispatch_async(dispatch_get_main_queue(), {
            
            
            cell.repositoryName.text = self.repositories[indexPath.row].valueForKey("repositoryName") as? String

            
        })
        
        // Return our new cell for display
        return cell
        
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "contributorSegue"
        {
            let destination = segue.destinationViewController as? ContributorViewController,
            repositoryIndex = tableView.indexPathForSelectedRow?.row
            destination!.repository  = (self.repositories[repositoryIndex!].valueForKey("repositoryName") as? String)!
        }
    }

}
