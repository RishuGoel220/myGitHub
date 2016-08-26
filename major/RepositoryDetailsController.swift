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
        APIcaller().getContributors(repositoryName){
            Result-> Void in
            if Result == true{
                self.displayTable()
            }
        }
        DatabaseHandler().addRepositoryStats(repositoryName, username: username)
        displayTable()
        
    }
    
    func displayTable(){
        self.contributors = DatabaseHandler().fetchAllContributors(repositoryName)
        self.tableView.reloadData()
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
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + contributors.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if indexPath.row == 0{
            return 125.0;//Choose your custom row height
        }
        else if indexPath.row == 3{
            return 60
        }
        else {
            return 100
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("repositoryDescriptionCell") as!
            repositoryDescriptionCell
            cell.descriptionLabel.text = DatabaseHandler().fetchRepositoryByName(repositoryName).first!.valueForKey("descriptionRepo") as? String
            cell.repositoryNameLabel.text = DatabaseHandler().fetchRepositoryByName(repositoryName).first!.valueForKey("repositoryName") as? String
            
            let URL = NSURL(string: (DatabaseHandler().fetchRepositoryByName(repositoryName).first?.avatarUrl)!)
            let placeholderImage = UIImage(named: "tabbutton")!
            cell.repoImage.af_setImageWithURL(URL!, placeholderImage: placeholderImage)
            
            
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("IssuesCell") as!
            IssuesCell
            setBoundary(cell.issuesView)
            cell.ClosedIssuesLabel.text = DatabaseHandler().fetchRepositoryByName(repositoryName).first!.closedIssues?.stringValue
            cell.OpenIssuesLabel.text = DatabaseHandler().fetchRepositoryByName(repositoryName).first!.openIssues?.stringValue
            imageSetUp(cell.closedIssueImage,name: "closedIssue")
            imageSetUp(cell.openIssueImage, name: "openIssue")
            cell.closedIssueImage.tintColor = UIColor.greenColor().colorWithAlphaComponent(0.5)
            cell.openIssueImage.tintColor = UIColor.redColor()
            
            return cell
        }
        else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("PRcell") as! PRcell
            setBoundary(cell.PRview)
            cell.ClosedPRLabel.text = DatabaseHandler().fetchRepositoryByName(repositoryName).first!.mergedPR?.stringValue
            cell.OpenPRLabel.text = DatabaseHandler().fetchRepositoryByName(repositoryName).first!.openPR?.stringValue
            imageSetUp(cell.closedPRImage, name: "openPR" )
            imageSetUp(cell.openPRImage, name: "closePR")
            cell.closedPRImage.tintColor = UIColor.greenColor().colorWithAlphaComponent(0.5)
            cell.openPRImage.tintColor = UIColor.purpleColor()
            return cell
        }
        else if indexPath.row == 3{
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
            cell.cellBoundary.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            setBoundary(cell.cellBoundary)
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("contributorPrototype") as! contributorCells
            
            cell.contributorsName.text = self.contributors[indexPath.row-4].valueForKey("contributorsName") as? String
            cell.contributions.text = self.contributors[indexPath.row-4].valueForKey("contributions") as? String
            setBoundary(cell.contributorCellBoundary)
            
            let URL = NSURL(string: (self.contributors[indexPath.row-4].valueForKey("avatarUrl") as? String)!)
            let placeholderImage = UIImage(named: "tabbutton")!
            cell.contributorImage.contentMode = UIViewContentMode.ScaleAspectFit
            cell.contributorImage.af_setImageWithURL(URL!, placeholderImage: placeholderImage)
            
            return cell
            
        }
    }
    
    func imageSetUp(imageview : UIImageView, name: String){
        imageview.contentMode = UIViewContentMode.ScaleAspectFit
        imageview.image = UIImage(named: name)
        imageview.image = imageview.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
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
    
   
    
    
    
    
    
}
