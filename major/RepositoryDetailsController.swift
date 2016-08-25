//
//  RepositoryDetailsController.swift
//  major
//
//  Created by Rishu Goel on 24/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import AlamofireImage
import KeychainAccess
import SwiftyJSON

class RepositoryDetailsController: UITableViewController {
    
    var repositoryName : String = ""
    var username: String = ""
    var contributors = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContributors()
        displayTable()
        getData()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "contributorDetailSegue"
        {
            let destination = segue.destinationViewController as! ContributorDetailController,
            repositoryIndex = tableView.indexPathForSelectedRow?.row
            destination.contributorName = (self.contributors[repositoryIndex!-4].valueForKey("contributorsName") as? String)!
            destination.repositoryName = repositoryName
        }
        
        
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + contributors.count
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.row == 0{
        return 150.0;//Choose your custom row height
        }
        else {
        return 100
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("repositoryDescriptionCell") as!
        repositoryDescriptionCell
        do{
            let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest(entityName: "Repositories")
            fetchRequest.predicate = NSPredicate(format: "repositoryName = %@ and users CONTAINS %@", self.repositoryName, RepositoryViewController().currentUser())
            let fetchResultsWithUser = try managedContext.executeFetchRequest(fetchRequest)
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("repositoryDescriptionCell") as!
                repositoryDescriptionCell
                cell.descriptionLabel.text = fetchResultsWithUser[0].valueForKey("descriptionRepo") as? String
                cell.repositoryNameLabel.text = fetchResultsWithUser[0].valueForKey("repositoryName") as? String
                
                let URL = NSURL(string: (fetchResultsWithUser[0].valueForKey("avatarUrl") as? String)!)
                let placeholderImage = UIImage(named: "tabbutton.png")!
                cell.repoImage.af_setImageWithURL(URL!, placeholderImage: placeholderImage)
                
                
                return cell
            }
            else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCellWithIdentifier("IssuesCell") as!
                IssuesCell
                setBoundary(cell.issuesView)
                cell.ClosedIssuesLabel.text = String(fetchResultsWithUser[0].valueForKey("closedIssues")!)
                cell.OpenIssuesLabel.text = String(fetchResultsWithUser[0].valueForKey("openIssues")!)
                
                
                
                
                
                cell.closedIssueImage.contentMode = UIViewContentMode.ScaleAspectFit
                cell.openIssueImage.image = UIImage(named: "openIssue.png")
                cell.openIssueImage.contentMode = UIViewContentMode.ScaleAspectFit
                cell.closedIssueImage.image = UIImage(named: "closedIssue.png")
                
                cell.closedIssueImage.image = cell.closedIssueImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.openIssueImage.image = cell.openIssueImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.closedIssueImage.tintColor = UIColor.greenColor().colorWithAlphaComponent(0.5)
                cell.openIssueImage.tintColor = UIColor.redColor()
                
                return cell
            }
            else if indexPath.row == 2 {
                let cell = tableView.dequeueReusableCellWithIdentifier("PRcell") as! PRcell
                setBoundary(cell.PRview)
                cell.ClosedPRLabel.text = String(fetchResultsWithUser[0].valueForKey("mergedPR")!)
                cell.OpenPRLabel.text = String(fetchResultsWithUser[0].valueForKey("openPR")!)
                
                
                
                cell.openPRImage.contentMode = UIViewContentMode.ScaleAspectFit
                cell.closedPRImage.contentMode = UIViewContentMode.ScaleAspectFit
                cell.openPRImage.image = UIImage(named: "openPR.png")
                cell.closedPRImage.image = UIImage(named: "closePR.png")
                
                cell.closedPRImage.image = cell.closedPRImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.openPRImage.image = cell.openPRImage.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.closedPRImage.tintColor = UIColor.greenColor().colorWithAlphaComponent(0.5)
                cell.openPRImage.tintColor = UIColor.purpleColor()
                return cell
            }
            else if indexPath.row == 3{
                let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
                cell.cellBoundary.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.1)
                setBoundary(cell.cellBoundary)
                return cell
            }
            else{
                let cell = tableView.dequeueReusableCellWithIdentifier("contributorPrototype") as! contributorCells
                cell.contributorsName.text = self.contributors[indexPath.row-4].valueForKey("contributorsName") as? String
                cell.contributions.text = self.contributors[indexPath.row-4].valueForKey("contributions") as? String
                setBoundary(cell.contributorCellBoundary)
                let URL = NSURL(string: (self.contributors[indexPath.row-4].valueForKey("avatarUrl") as? String)!)
                let placeholderImage = UIImage(named: "tabbutton.png")!
                cell.contributorImage.af_setImageWithURL(URL!, placeholderImage: placeholderImage)
                return cell
            
            }
        }
        catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setBoundary(cellview : UIView){
        cellview.layer.shadowColor = UIColor.blackColor().CGColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSizeZero
        cellview.layer.shadowRadius = 1
    }
    
    func getData(){
        //self.getContributors(repositoryName)
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        APIcaller().getPRCount(repositoryName, username : username){
            (PR: [Int])-> Void in
            do {
                
                let fetchRequest = NSFetchRequest(entityName: "Repositories")
                fetchRequest.predicate = NSPredicate(format: "repositoryName = %@ and users CONTAINS %@", self.repositoryName, RepositoryViewController().currentUser())
                let fetchResultsWithUser =
                    try managedContext.executeFetchRequest(fetchRequest)
                if fetchResultsWithUser.count != 0{
                    fetchResultsWithUser[0].setValue(PR[0], forKey: "openPR")
                    fetchResultsWithUser[0].setValue(PR[1], forKey: "mergedPR")
                    
                    try managedContext.save()
                    
                }
                
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            
            
        }
        
        
        APIcaller().getIssueCount(repositoryName, username : username){
            (Issues: [Int])-> Void in
            do {
                
                let fetchRequest = NSFetchRequest(entityName: "Repositories")
                fetchRequest.predicate = NSPredicate(format: "repositoryName = %@ and users CONTAINS %@", self.repositoryName, RepositoryViewController().currentUser())
                let fetchResultsWithUser =
                    try managedContext.executeFetchRequest(fetchRequest)
                if fetchResultsWithUser.count != 0{
                    fetchResultsWithUser[0].setValue(Issues[0], forKey: "openIssues")
                    fetchResultsWithUser[0].setValue(Issues[1], forKey: "closedIssues")
                    
                    try managedContext.save()
                    
                }
                
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
            
        }
        
    }
    public func getContributors(){
        //let deleteresults = deleteAllData("Contributors")
        
        // Alamofire request
        let keychain = Keychain(service: "com.example.Practo.major")
        let headers = ["Authorization": "bearer \(keychain["Auth_token"]! as String)"]
        Alamofire.request(.GET, "https://api.github.com/repos/\(RepositoryViewController().currentUser().valueForKey("username") as! String)/"+self.repositoryName+"/contributors", parameters: [:], headers: headers)
            .responseJSON { response in
                let json = JSON(response.result.value!)
                
                let appDelegate =
                    UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext = appDelegate.managedObjectContext
                
                let fetchRequest = NSFetchRequest(entityName: "Repositories")
                fetchRequest.predicate = NSPredicate(format: "repositoryName == %@ and users CONTAINS %@", self.repositoryName, DatabaseHandler().currentUser())
                
                
                
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
                        fetchRequest.predicate = NSPredicate(format: "contributorsName == %@ and repository == %@ ", name, results[0] as! NSManagedObject)
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
                        
                        contribute.setValue(results[0], forKey: "repository")
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
            let fetchRequest = NSFetchRequest(entityName: "Repositories")
            fetchRequest.predicate = NSPredicate(format: "repositoryName == %@ and users CONTAINS %@", self.repositoryName, DatabaseHandler().currentUser())
            
            //3
            do {
                
                let results =
                    try managedContext.executeFetchRequest(fetchRequest)
                
                let fetchRequest = NSFetchRequest(entityName: "Contributors")
                fetchRequest.predicate = NSPredicate(format: " repository == %@ ", results[0] as! NSManagedObject)
                let fetchresults =
                    try managedContext.executeFetchRequest(fetchRequest)
                print(fetchresults as! [NSManagedObject])
                self.contributors = fetchresults as! [NSManagedObject]
                debugPrint(self.contributors)
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
        })
    }
    
}
