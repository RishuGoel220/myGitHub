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
import KeychainAccess

class RepositoryViewController: UITableViewController {
    
    var repositories = [NSManagedObject]()
    
    @IBAction func favButtonClicked(sender: AnyObject) {
        let appDel: AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        let context: NSManagedObjectContext = appDel.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Repositories")
        fetchRequest.predicate = NSPredicate(format: "repositoryName = %@", (self.repositories[sender.tag].valueForKey("repositoryName") as? String)!)
        
        
        do {
            let fetchResults =
                try appDel.managedObjectContext.executeFetchRequest(fetchRequest)
                if fetchResults.count != 0{
    
                    let managedObject = fetchResults[0]
                    let boolvalue = fetchResults[0].valueForKey("isFavourite") as? String
                    if boolvalue=="false" {
                        managedObject.setValue("true", forKey: "isFavourite")
                    }
                    else{
                        managedObject.setValue("false", forKey: "isFavourite")
                    }
                    try context.save()
                    displayData()
                }

        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(RepositoryViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refreshControl!)
        if Reachability.isConnectedToNetwork() == true {
            displayData()
            getRepositories()
        } else {
            displayData()
        }
        
    }
    
    
    func refresh(sender:AnyObject) {
        
        getRepositories()
        
    }
    
    func getRepositories(){
        Alamofire.request(.GET, "https://api.github.com/orgs/practo/repos", parameters: [:])
            .responseJSON { response in
                let json = JSON(response.result.value!)
                
                for item in json.arrayValue {
                    let name = item["name"].stringValue
                    let descriptionRepo = item["description"].stringValue
                    let appDelegate =
                        UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext
                    
                    
                    let fetchRequest = NSFetchRequest(entityName: "Repositories")
                    fetchRequest.predicate = NSPredicate(format: "repositoryName = %@", name)
                    
                    
                    do {
                        let fetchResults =
                            try managedContext.executeFetchRequest(fetchRequest)
                        if fetchResults.count != 0{
                            continue
                        }
                        
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                    }
                    
                    
                    
                    
                    
                    
                    
                    
                    //2
                    let entity =  NSEntityDescription.entityForName("Repositories",
                        inManagedObjectContext:managedContext)
                    
                    let repo = NSManagedObject(entity: entity!,
                        insertIntoManagedObjectContext: managedContext)
                    
                    //3
                    repo.setValue(name, forKey: "repositoryName")
                    repo.setValue("false", forKey: "isFavourite")
                    repo.setValue(descriptionRepo, forKey: "descriptionRepo")
                    
                    //4
                    do {
                        try managedContext.save()
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
        refreshControl!.endRefreshing()
    }
//    
//    func deleteAllData(entity: String)
//    {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
//        let fetchRequest = NSFetchRequest(entityName: entity)
//        fetchRequest.returnsObjectsAsFaults = false
//        
//        do
//        {
//            let results = try managedContext.executeFetchRequest(fetchRequest)
//            for managedObject in results
//            {
//                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
//                managedContext.deleteObject(managedObjectData)
//            }
//        } catch let error as NSError {
//            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
//        }
//    }
    
    
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
            
            if self.repositories[indexPath.row].valueForKey("isFavourite") as? String == "true"{
                cell.favButton.setImage(UIImage(named: "filledstar.png"), forState: UIControlState.Normal)
            }else{
                cell.favButton.setImage(UIImage(named: "unfilledstar.png"), forState: UIControlState.Normal)
            }
            cell.repositoryName.text = self.repositories[indexPath.row].valueForKey("repositoryName") as? String

            
        })
        
        // Return our new cell for display
        return cell
        
    }
    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let message = "Description : \(self.repositories[indexPath.row].valueForKey("descriptionRepo") as! String)"
        let alert = UIAlertView(title: "\(self.repositories[indexPath.row].valueForKey("repositoryName") as! String) ", message: message, delegate: self, cancelButtonTitle: "OK")
        alert.show()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "contributorSegue"
        {
            let destination = segue.destinationViewController as? ContributorViewController,
            repositoryIndex = tableView.indexPathForSelectedRow?.row
            destination!.repository  = (self.repositories[repositoryIndex!].valueForKey("repositoryName") as? String)!
        }
        
        if  segue.identifier == "logoutSegue"
        {
            let destination = segue.destinationViewController as? ViewController
            let keychain = Keychain(service: "com.example.Practo.major")
            do {
              try keychain.remove("Auth_token")
            } catch let error {
              print("error: \(error)")
            }
        }
    }

}
