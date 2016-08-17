//
//  ContributorViewController.swift
//  major
//
//  Created by Rishu Goel on 16/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class ContributorViewController: UITableViewController {
    
    var repository:String = ""
    var contributors = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Reachability.isConnectedToNetwork() == true {
            getContributors()
        } else {
            displayData()
        }
        
    }
    
    
    func getContributors(){
        self.deleteAllData("Contributors")
        Alamofire.request(.GET, "https://api.github.com/repos/practo/"+repository+"/contributors", parameters: [:])
            .responseJSON { response in
                let json = JSON(response.result.value!)
                
                for item in json.arrayValue {
                    var name = item["login"].stringValue
                    let appDelegate =
                        UIApplication.sharedApplication().delegate as! AppDelegate
                    
                    let managedContext = appDelegate.managedObjectContext
                    
                    //2
                    let entity =  NSEntityDescription.entityForName("Contributors",
                        inManagedObjectContext:managedContext)
                    
                    let contribute = NSManagedObject(entity: entity!,
                        insertIntoManagedObjectContext: managedContext)
                    
                    //3
                    contribute.setValue(self.repository, forKey: "repositoryName")
                    contribute.setValue(name, forKey: "contributorsName")
                    
                    //4
                    do {
                        try managedContext.save()
                        self.contributors.append(contribute)
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
            let fetchRequest = NSFetchRequest(entityName: "Contributors")
            fetchRequest.predicate = NSPredicate(format: "repositoryName == %@", self.repository)
            //3
            do {
                let results =
                    try managedContext.executeFetchRequest(fetchRequest)
                self.contributors = results as! [NSManagedObject]
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
        fetchRequest.predicate = NSPredicate(format: "repositoryName == %@", self.repository)
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
        return contributors.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contributorPrototype") as! contributorCells
        // Set the first row text label to the firstRowLabel data in our current array item
        dispatch_async(dispatch_get_main_queue(), {
            
            
            cell.contributorsName.text = self.contributors[indexPath.row].valueForKey("contributorsName") as? String
            cell.linesAdded.text = "45"
            cell.linesDeleted.text = "45"
            
            
        })
        // Return our new cell for display
        return cell
        
    }

}
