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

//------------------------------------------------------------------------------
// DESCRIPTION: This is the Controller for the screen of repository Details for
//              particular repository.
//------------------------------------------------------------------------------
class RepositoryDetailsController: UITableViewController {
    
// MARK: Global Variables
//------------------------- Global Variables -----------------------------
    var repositoryName : String = ""
    var username: String = ""
    var contributors = [NSManagedObject]()

// MARK: View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // fetch contributors
        dataHandler().getContributors(repositoryName){
            Result-> Void in
            if Result == true{
                // fetch extra repository details
                dataHandler().getPRCount(self.repositoryName, username: self.username){
                    result in
                    self.displayTable()
                }
                dataHandler().getIssueCount(self.repositoryName, username: self.username){
                    result in
                    self.displayTable()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // fetch contributor data from database and display
    func displayTable(){
        self.contributors = DatabaseHandler().fetchAllContributors(repositoryName)
        self.tableView.reloadData()
    }
    
    // segue for table rows
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "contributorDetailSegue"
        {
            let destination = segue.destinationViewController as! ContributorDetailController,
            repositoryIndex = tableView.indexPathForSelectedRow?.row
            
            // pass the contributor name of the cell clicked
            destination.contributorName = (self.contributors[repositoryIndex!-4].valueForKey("contributorsName") as? String)!
            destination.repositoryName = repositoryName
        }
    }
    
    
    // first 4 cells are fixed and others are based on numbers of contributors
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 + contributors.count
    }

// Table view function to give height to cell based on its index
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        // repository detail cell has to be bigger than else
        if indexPath.row == 0{
            return 125.0;
        }
        // heading cell for contributors has to be small
        else if indexPath.row == 3{
            return 60
        }
    
        else {
            return 100
        }
    }

// Table view function to fill data into cells and provide the cell for rendering
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // first cell has to a repository Description cell with image, name
        // and description
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
        // Issue Card with issue counts and icons for the same
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
        // PR card with pr counts and icons for the same
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
        // a header for contributions
        else if indexPath.row == 3{
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! HeaderCell
            cell.cellBoundary.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            setBoundary(cell.cellBoundary)
            return cell
        }
        // contributor cells with basic contributor data
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
    
// MARK: UI enhancement functions
    
    // To put given named image in the given image view
    func imageSetUp(imageview : UIImageView, name: String){
        imageview.contentMode = UIViewContentMode.ScaleAspectFit
        imageview.image = UIImage(named: name)
        // make the image editable
        imageview.image = imageview.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    }
    
    // To make the boundary for the cell to make it look like a card
    func setBoundary(cellview : UIView){
        cellview.layer.shadowColor = UIColor.blackColor().CGColor
        cellview.layer.shadowOpacity = 0.5
        cellview.layer.shadowOffset = CGSizeZero
        cellview.layer.shadowRadius = 1
    }
    
    
    
    
}
