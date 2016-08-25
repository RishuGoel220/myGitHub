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
import KeychainAccess
import AlamofireImage

class contributorViewController: UITableViewController {
    
    var repository:String = ""
    var userLoggedIn:String = ""
    var contributors = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(contributorViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        self.tableView.addSubview(refreshControl!)
        
        if Reachability.isConnectedToNetwork() == true {
            displayTable()
            getContributors(self.repository)
        } else {
            displayTable()
        }
        
    }
    func refresh(sender:AnyObject) {
        
        getContributors(self.repository)
        
    }
    
    public func getContributors(repository: String){
        //let deleteresults = deleteAllData("Contributors")
        
        // Alamofire request
        let keychain = Keychain(service: "com.example.Practo.major")
        let headers = ["Authorization": "bearer \(keychain["Auth_token"]! as String)"]
        Alamofire.request(.GET, "https://api.github.com/repos/\(RepositoryViewController().currentUser().valueForKey("username") as! String)/"+repository+"/contributors", parameters: [:], headers: headers)
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
                            if fetchResults.count != 0{
                                fetchResults[0].setValue(contributions, forKey: "contributions")
                                fetchResults[0].setValue(avatarUrl, forKey: "avatarUrl")
                                try managedContext.save()
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
                self.displayTable()
                
        }
    }

    
    
    
    
    func displayTable(){
        debugPrint("display data called")
        dispatch_async(dispatch_get_main_queue(), {
            let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "Contributors")
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contributors.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contributorPrototype") as! contributorCells
        cell.contributorCellBoundary.layer.shadowColor = UIColor.blackColor().CGColor
        cell.contributorCellBoundary.layer.shadowOpacity = 0.5
        cell.contributorCellBoundary.layer.shadowOffset = CGSizeZero
        cell.contributorCellBoundary.layer.shadowRadius = 1
        // Set the first row text label to the firstRowLabel data in our current array item
        dispatch_async(dispatch_get_main_queue(), {
            
            
            cell.contributorsName.text = self.contributors[indexPath.row].valueForKey("contributorsName") as? String
            cell.contributions.text = self.contributors[indexPath.row].valueForKey("contributions") as? String
            
            let URL = NSURL(string: (self.contributors[indexPath.row].valueForKey("avatarUrl") as? String)!)
            let placeholderImage = UIImage(named: "tabbutton.png")!
            cell.contributorImage.af_setImageWithURL(URL!, placeholderImage: placeholderImage)
            
            self.circularImageView(cell.contributorImage)
            
            
            
        })
        // Return our new cell for display
        return cell
        
    }
    
    func circularImageView(imageView : UIImageView){
        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = false
        imageView.layer.borderColor = UIColor.blackColor().CGColor
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.clipsToBounds = true
        
    }

}
