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
    
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    
    
//-------------------------- LOGOUT FUNCTIONS ------------------------------
    
    @IBAction func logoutAction(sender: AnyObject) {
        showAlertForLogOut()
        
    }
    
    func showAlertForLogOut() {
        let alert = UIAlertController(title: "Caution!", message: "Are you sure you want to Logout ?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { action in
            KeychainHandler().removeAuthToken()
            DatabaseHandler().changeCurrentUser()
            self.appDelegate.resetAppToFirstController()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel , handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

//------------------- Favourite Button Click Function ----------------------
    @IBAction func favButtonClicked(sender: AnyObject) {
        let context: NSManagedObjectContext = appDelegate.managedObjectContext
        let repositoryName = (self.repositories[sender.tag].valueForKey("repositoryName") as? String)!
        DatabaseHandler().changeIsFavouriteState(repositoryName)
        displayData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControlSetup()
        if Reachability.isConnectedToNetwork() == true {
            displayData()
            getRepositories()
        } else {
            displayData()
        }
        
    }
    

    
    func getRepositories(){
        let username = currentUser().valueForKey("username") as! String
        let keychain = Keychain(service: "com.example.Practo.major")
        let headers = ["Authorization": "bearer \(keychain["Auth_token"]! as String)"]
        Alamofire.request(.GET, "https://api.github.com/users/\(currentUser().valueForKey("username") as! String)/repos", parameters: [:], headers: headers)
            .responseJSON { response in
                
                
                switch response.result {
                case let .Success(successvalue):
                    let json = JSON(response.result.value!)
                    for item in json.arrayValue {
                    
                    let name = item["name"].stringValue
                    let descriptionRepo = item["description"].stringValue
                    let avatarUrl =  item["owner"]["avatar_url"].stringValue
                    
                    
                    print(name)
                    let appDelegate =
                        UIApplication.sharedApplication().delegate as! AppDelegate
                    let managedContext = appDelegate.managedObjectContext
                    
                    // check if the repository exists
                    do {
                        let fetchRequest = NSFetchRequest(entityName: "Repositories")
                        fetchRequest.predicate = NSPredicate(format: "repositoryName = %@", name)
                        let fetchResults =
                            try managedContext.executeFetchRequest(fetchRequest)
                        if fetchResults.count != 0{
                            do {
                                
                                let fetchRequest = NSFetchRequest(entityName: "Repositories")
                                fetchRequest.predicate = NSPredicate(format: "repositoryName = %@ and users CONTAINS %@", name, self.currentUser())
                                let fetchResultsWithUser =
                                    try managedContext.executeFetchRequest(fetchRequest)
                                if fetchResultsWithUser.count != 0{
                                    fetchResultsWithUser[0].setValue(descriptionRepo, forKey: "descriptionRepo")
                                    fetchResultsWithUser[0].setValue(avatarUrl, forKey: "avatarUrl")
                                    try managedContext.save()
                                    continue
                                }
                                
                            } catch let error as NSError {
                                print("Could not fetch \(error), \(error.userInfo)")
                            }
                            
                        }
                        
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                    }
                    
                    //if repository doesnt exist
                    
                    let entity =  NSEntityDescription.entityForName("Repositories",
                        inManagedObjectContext:managedContext)
                    
                    let repo = NSManagedObject(entity: entity!,
                        insertIntoManagedObjectContext: managedContext)
                    
                    //3
                    repo.setValue(name, forKey: "repositoryName")
                    repo.setValue("false", forKey: "isFavourite")
                    repo.setValue(descriptionRepo, forKey: "descriptionRepo")
                    repo.setValue(avatarUrl, forKey: "avatarUrl")
                    repo.setValue(NSSet(object : self.currentUser()), forKey: "users")
                    //4
                    do {
                        try managedContext.save()
                    } catch let error as NSError  {
                        print("Could not save \(error), \(error.userInfo)")
                    }
                    
                }
                self.displayData()
            case let .Failure(errorvalue):
                    self.refreshControl!.endRefreshing()
                    print(errorvalue)
            }
        }
    }
    
    
    func displayData(){
        dispatch_async(dispatch_get_main_queue(), {
            
            
            let managedContext = self.appDelegate.managedObjectContext
            
            //2
            let fetchRequest = NSFetchRequest(entityName: "Repositories")
            fetchRequest.predicate = NSPredicate(format: "users CONTAINS %@", self.currentUser())
            fetchRequest.returnsObjectsAsFaults = false
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
        cell.view.layer.shadowColor = UIColor.blackColor().CGColor
        cell.view.layer.shadowOpacity = 0.5
        cell.view.layer.shadowOffset = CGSizeZero
        cell.view.layer.shadowRadius = 1
        dispatch_async(dispatch_get_main_queue(), {
            
            
            if self.repositories[indexPath.row].valueForKey("isFavourite") as? String == "true"{
                cell.favButton.setImage(UIImage(named: "heartfilled.png"), forState: UIControlState.Normal)
            }else{
                cell.favButton.setImage(UIImage(named: "heartunfilled.png"), forState: UIControlState.Normal)
            }
            cell.repositoryName.text = self.repositories[indexPath.row].valueForKey("repositoryName") as? String
            cell.descriptionLabel.text = self.repositories[indexPath.row].valueForKey("descriptionRepo") as? String
            let URL = NSURL(string: (self.repositories[indexPath.row].valueForKey("avatarUrl") as? String)!)
            let placeholderImage = UIImage(named: "tabbutton.png")!
        
            cell.repositoryImage.layer.borderWidth = 1.0
            cell.repositoryImage.layer.masksToBounds = false
            
            cell.repositoryImage.layer.borderColor = UIColor.whiteColor().CGColor
            cell.repositoryImage.layer.cornerRadius = cell.repositoryImage.frame.size.height/2
            cell.repositoryImage.layer.cornerRadius = 10
            cell.repositoryImage.clipsToBounds = true
            cell.repositoryImage
                .af_setImageWithURL(URL!, placeholderImage: placeholderImage)
            
        })
        
        // Return our new cell for display
        return cell
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "RepositoryDescriptionPage"
        {
            let destination = segue.destinationViewController as! RepositoryDetailsController,
            repositoryIndex = tableView.indexPathForSelectedRow?.row
            destination.repositoryName = (self.repositories[repositoryIndex!].valueForKey("repositoryName") as? String)!
            destination.username = self.currentUser().valueForKey("username") as! String
        }
        
        
    }
    
    func currentUser()-> NSManagedObject{
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Users")
        fetchRequest.predicate = NSPredicate(format: "current = \"yes\"")
        
        do {
            let fetchResults =
                try managedContext.executeFetchRequest(fetchRequest)
            let managedObject = fetchResults[0]
            return managedObject as! NSManagedObject
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        let dummy = NSManagedObject()
        return dummy
    }
    
    func refreshControlSetup(){
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(RepositoryViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        var inset = UIEdgeInsetsMake(5, 0, 0, 0);
        self.tableView.contentInset = inset;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.addSubview(refreshControl!)
        
    }
    
    func refresh(sender:AnyObject) {
        
        getRepositories()
        
    }

    
    
    

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

//    func printUsers(){
//        let appDelegate =
//            UIApplication.sharedApplication().delegate as! AppDelegate
//
//        let managedContext = appDelegate.managedObjectContext
//
//        do {
//              print(self.currentUser())
//
//        } catch let error as NSError {
//            print("Could not fetch \(error), \(error.userInfo)")
//        }
//    }
