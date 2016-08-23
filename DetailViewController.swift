//
//  DetailViewController.swift
//  
//
//  Created by Rishu Goel on 23/08/16.
//
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON
import KeychainAccess

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var ClosedIssuesLabel: UILabel!
    @IBOutlet weak var OpenIssuesLabel: UILabel!
    @IBOutlet weak var OpenPRLabel: UILabel!
    @IBOutlet weak var ClosedPRLabel: UILabel!
    
    @IBOutlet weak var tableHolder: UIView!
    @IBOutlet weak var repoImage: UIImageView!
    
    @IBOutlet weak var PRview: UIView!
    @IBOutlet weak var issuesView: UIView!
    
    @IBOutlet weak var contributorTable: UITableView!
    
    @IBOutlet weak var closedIssueImage: UIImageView!
    @IBOutlet weak var openIssueImage: UIImageView!
    @IBOutlet weak var closedPRImage: UIImageView!
    @IBOutlet weak var openPRImage: UIImageView!
    
    var contributors = [NSManagedObject]()
    var repositoryName: String = ""
    var username: String = ""
    
    
    override func viewDidLoad(){
        self.contributorTable.delegate = self
        self.contributorTable.dataSource = self
        PRview.layer.shadowColor = UIColor.blackColor().CGColor
        PRview.layer.shadowOpacity = 0.5
        PRview.layer.shadowOffset = CGSizeZero
        PRview.layer.shadowRadius = 1
        tableHolder.layer.shadowColor = UIColor.blackColor().CGColor
        tableHolder.layer.shadowOpacity = 0.5
        tableHolder.layer.shadowOffset = CGSizeZero
        tableHolder.layer.shadowRadius = 1
        issuesView.layer.shadowColor = UIColor.blackColor().CGColor
        issuesView.layer.shadowOpacity = 0.5
        issuesView.layer.shadowOffset = CGSizeZero
        issuesView.layer.shadowRadius = 1
        super.viewDidLoad()
        if Reachability.isConnectedToNetwork() == true {
            displayData()
            getData()
        } else {
            displayData()
        }
        
    }
    
    
    func displayData(){
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        do {
            
            let fetchRequest = NSFetchRequest(entityName: "Repositories")
            fetchRequest.predicate = NSPredicate(format: "repositoryName = %@ and users CONTAINS %@", self.repositoryName, RepositoryViewController().currentUser())
            let fetchResultsWithUser =
                try managedContext.executeFetchRequest(fetchRequest)
            if fetchResultsWithUser.count != 0{
                self.ClosedPRLabel.text = String(fetchResultsWithUser[0].valueForKey("mergedPR")!)
                self.OpenPRLabel.text = String(fetchResultsWithUser[0].valueForKey("openPR")!)
                self.ClosedIssuesLabel.text = String(fetchResultsWithUser[0].valueForKey("closedIssues")!)
                self.OpenIssuesLabel.text = String(fetchResultsWithUser[0].valueForKey("openIssues")!)
                self.descriptionLabel.text = fetchResultsWithUser[0].valueForKey("descriptionRepo") as? String
                let URL = NSURL(string: (fetchResultsWithUser[0].valueForKey("avatarUrl") as? String)!)
                let placeholderImage = UIImage(named: "tabbutton.png")!
                self.repoImage.af_setImageWithURL(URL!, placeholderImage: placeholderImage)
                self.repositoryNameLabel.text = repositoryName
                self.closedIssueImage.contentMode = UIViewContentMode.ScaleAspectFit
                self.closedIssueImage.image = UIImage(named: "closedIssue.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                self.closedIssueImage.tintColor = UIColor.greenColor().colorWithAlphaComponent(0.40)
                
                self.openPRImage.contentMode = UIViewContentMode.ScaleAspectFit
                self.openPRImage.image = UIImage(named: "openPR.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                self.openPRImage.tintColor = UIColor.purpleColor()
                
                self.openIssueImage.contentMode = UIViewContentMode.ScaleAspectFit
                self.openIssueImage.image = UIImage(named: "openIssue.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                self.openIssueImage.tintColor = UIColor.redColor()
                
                self.closedPRImage.contentMode = UIViewContentMode.ScaleAspectFit
                self.closedPRImage.image = UIImage(named: "closePR.png")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                self.closedPRImage.tintColor = UIColor.greenColor().colorWithAlphaComponent(0.40)
                

            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        
        
        
        
    }

    func displayTable(){
        dispatch_async(dispatch_get_main_queue(), {
            let appDelegate =
                UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = appDelegate.managedObjectContext
            
            //2
            let fetchRequest = NSFetchRequest(entityName: "Contributors")
            
            fetchRequest.predicate = NSPredicate(format: " repository.repositoryName CONTAINS %@", self.repositoryName)
            
            //3
            do {
                let results =
                    try managedContext.executeFetchRequest(fetchRequest)
                print(results as! [NSManagedObject])
                self.contributors = results as! [NSManagedObject]
                debugPrint(self.contributors)
                self.contributorTable.reloadData()
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
        })

    }


    func getData(){
        self.getContributors(repositoryName)
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
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if contributors.count<3{
        return contributors.count
        }
        else{
            return 3
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("contributorDetailViewCell") as! contributorDetailViewCell
        dispatch_async(dispatch_get_main_queue(), {
            
            
            cell.contributorsName.text = self.contributors[indexPath.row].valueForKey("contributorsName") as? String
            cell.contributions.text = self.contributors[indexPath.row].valueForKey("contributions") as? String
            })
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("openContributorScene", sender: indexPath)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "openContributorScene"
        {
            let destination = segue.destinationViewController as? contributorViewController
            destination!.repository  = repositoryName
        }
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
                fetchRequest.predicate = NSPredicate(format: "repositoryName == %@", self.repositoryName)
                
                
                
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
                        fetchRequest.predicate = NSPredicate(format: "contributorsName == %@ and repository.repositoryName CONTAINS %@ " ,name,self.repositoryName)
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
                
                //debugPrint("AALMAOFIRE  \n")
                //debugPrint(self.contributors)
                
                //for managedObject in deleteresults as! [AnyObject]
                //{
                
                //    let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                //   managedContext.deleteObject(managedObjectData)
                //}
                //debugPrint("delete old contributor")
                //debugPrint(self.contributors)
                self.displayTable()
                
        }
    }

    

}
