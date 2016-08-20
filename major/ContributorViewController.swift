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
import AlamofireImage

class ContributorViewController: UITableViewController {
    
    var repository:String = ""
    var userLoggedIn:String = ""
    var contributors = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(ContributorViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refreshControl!)
        
        if Reachability.isConnectedToNetwork() == true {
            displayData()
            getContributors()
        } else {
            displayData()
        }
        
    }
    func refresh(sender:AnyObject) {
        
        getContributors()
        
    }
    
    func getContributors(){
        //let deleteresults = deleteAllData("Contributors")
        
        // Alamofire request
        Alamofire.request(.GET, "https://api.github.com/repos/rishugoel220/"+repository+"/contributors", parameters: [:], headers: [:])
            .responseJSON { response in
                let json = JSON(response.result.value!)
                
                debugPrint("alamofire contributor")
                let appDelegate =
                    UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext = appDelegate.managedObjectContext
                
                let fetchRequest = NSFetchRequest(entityName: "Repositories")
                fetchRequest.predicate = NSPredicate(format: "repositoryName == %@", self.repository)

                
                
                for item in json.arrayValue {
                    let name = item["login"].stringValue
                    let contributions = item["contributions"].stringValue
                    let avatarUrl = item["avatar_url"].stringValue
                    print(contributions)
                    print("hi")
                    //3
                    
                    do {
                        
                        let results =
                            try managedContext.executeFetchRequest(fetchRequest)
                        
                        // check for duplicate
                        
                        let fetchRequest = NSFetchRequest(entityName: "Contributors")
                        fetchRequest.predicate = NSPredicate(format: "contributorsName == %@ and repository.repositoryName CONTAINS %@ " ,name,self.repository)
                        do {
                            let fetchResults =
                                try managedContext.executeFetchRequest(fetchRequest)
                            print(fetchResults)
                            print("hihihihihihih")
                            if fetchResults.count != 0{
                                continue
                            }
                            
                        }
                        
                        
                        // if not present add
                        let entity =  NSEntityDescription.entityForName("Contributors",
                            inManagedObjectContext:managedContext)
                        
                        let contribute = NSManagedObject(entity: entity!,
                            insertIntoManagedObjectContext: managedContext)
                        
                        contribute.setValue(NSSet(object: results[0]), forKey: "repository")
                        contribute.setValue(name, forKey: "contributorsName")
                        contribute.setValue(contributions, forKey:"contributions")
                        contribute.setValue(avatarUrl, forKey: "avatarUrl")

                        do {
                            try managedContext.save()
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                    }
                    
        
                }
                
                //debugPrint("AALMAOFIRE  \n")
                //debugPrint(self.contributors)
                
                //for managedObject in deleteresults as! [AnyObject]
                //{
                    
                //    let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                 //   managedContext.deleteObject(managedObjectData)
                //}
                //debugPrint("delete old contributor")
                //debugPrint(self.contributors)
                self.displayData()
                
        }
    }

    
    
    
    
    func displayData(){
        debugPrint("display data called")
        dispatch_async(dispatch_get_main_queue(), {
            let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            //2
            let fetchRequest = NSFetchRequest(entityName: "Contributors")
//            do {
//                let results =
//                    try managedContext.executeFetchRequest(fetchRequest)
//                let res = results
//                print(res.valueForKey("contributorsName").array)
//                
//            }catch{
//            }
            fetchRequest.predicate = NSPredicate(format: " repository.repositoryName CONTAINS %@", self.repository)
            
            //3
            do {
                let results =
                    try managedContext.executeFetchRequest(fetchRequest)
                print(results as! [NSManagedObject])
                self.contributors = results as! [NSManagedObject]
                debugPrint(self.contributors)
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
        })
        
        refreshControl!.endRefreshing()
    }
    
    
//    func deleteAllData(entity: String) -> AnyObject
//    {
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
//        let fetchRequest = NSFetchRequest(entityName: entity)
//        fetchRequest.predicate = NSPredicate(format: "Any repository.repositoryName == %@", self.repository)
//        fetchRequest.returnsObjectsAsFaults = false
//        
//        do
//        {
//            let results = try managedContext.executeFetchRequest(fetchRequest)
//            return results
//            
//        } catch let error as NSError {
//            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
//        }
//        return 0
//    }
    
    
    
    
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
            cell.contributions.text = self.contributors[indexPath.row].valueForKey("contributions") as? String
            let URL = NSURL(string: (self.contributors[indexPath.row].valueForKey("avatarUrl") as? String)!)
            let placeholderImage = UIImage(named: "tabbutton.png")!
            
            cell.contributorImage.af_setImageWithURL(URL!, placeholderImage: placeholderImage)
            
            
        })
        // Return our new cell for display
        return cell
        
    }

}
