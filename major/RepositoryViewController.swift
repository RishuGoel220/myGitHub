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
    
// MARK: Functions for Actions for Buttons
//-------------------------- LOGOUT FUNCTION ------------------------------
    
    @IBAction func logoutAction(sender: AnyObject) {
        let alert = UtilityHandler().showAlertWithSingleButton("Caution !", message: "Are you sure you want to Logout ?")
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { action in
            KeychainHandler().removeAuthToken()
            DatabaseHandler().changeCurrentUser()
            self.appDelegate.resetAppToFirstController()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }


//------------------- Favourite Button Click Function ----------------------
    @IBAction func favButtonClicked(sender: AnyObject) {
        let repositoryName = (self.repositories[sender.tag].valueForKey("repositoryName") as? String)!
        DatabaseHandler().changeIsFavouriteState(repositoryName)
        displayData()
    }
    
// MARK: View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControlSetup()
        if Reachability.isConnectedToNetwork() == true {
            displayData()
            APIcaller().getRepositories(){
                Result -> Void in
                if Result == true {
                    self.displayData()
                }
            }
        }
        else {
            displayData()
        }
        
    }
    
    func displayData(){
        self.repositories = DatabaseHandler().fetchAllRepositories()
        self.tableView.reloadData()
        refreshControl!.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "RepositoryDescriptionPage"
        {
            let destination = segue.destinationViewController as! RepositoryDetailsController,
            repositoryIndex = tableView.indexPathForSelectedRow?.row
            destination.repositoryName = (self.repositories[repositoryIndex!].valueForKey("repositoryName") as? String)!
            destination.username = DatabaseHandler().currentUser().valueForKey("username") as! String
        }
    }
    
// MARK: Table View Functions
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellPrototype") as! repositoryCells
        
        setUpFavButtons(cell.favButton, row: indexPath.row)
        makeBoundaryForView(cell.view)
        makeImageCircular(cell.repositoryImage)
        
    // Set Image to Favourite Button
        if self.repositories[indexPath.row].valueForKey("isFavourite") as? String == "true"{
            cell.favButton.setImage(UIImage(named: "heartfilled"), forState: UIControlState.Normal)}
        else{
            cell.favButton.setImage(UIImage(named: "heartunfilled"), forState: UIControlState.Normal)}
        
    // Set Text Fields
        cell.repositoryName.text = self.repositories[indexPath.row].valueForKey("repositoryName") as? String
        cell.descriptionLabel.text = self.repositories[indexPath.row].valueForKey("descriptionRepo") as? String
        
    //  SET Image to the image view
        let URL = NSURL(string: (self.repositories[indexPath.row].valueForKey("avatarUrl") as? String)!)
        let placeholderImage = UIImage(named: "tabbutton")!
        cell.repositoryImage.contentMode = UIViewContentMode.ScaleAspectFit
        cell.repositoryImage
            .af_setImageWithURL(URL!, placeholderImage: placeholderImage)
        
        return cell
    }
    
// MARK: UI functions
//-------------------- Functions to improve the  design -------------------------------
    func makeImageCircular(view: UIImageView){
        view.layer.borderWidth = 1.0
        view.layer.masksToBounds = false
        view.layer.borderColor = UIColor.whiteColor().CGColor
        view.layer.cornerRadius = view.frame.size.height/2
        view.clipsToBounds = true
        
    }
    
    func makeBoundaryForView(view: UIView){
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSizeZero
        view.layer.shadowRadius = 1
    }
    
    func setUpFavButtons(button: UIButton, row: Int){
        button.tag = row
        button.addTarget(self, action: #selector(favButtonClicked(_:)), forControlEvents: .TouchUpInside)
    }
    
    
    
    
    
    

// MARK: Refresh Control
    func refreshControlSetup(){
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(RepositoryViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.addSubview(refreshControl!)
        
    }
    
    func refresh(sender:AnyObject) {
        APIcaller().getRepositories(){
            Result-> Void in
            self.displayData()
            self.refreshControl!.endRefreshing()
        }
        
    }

    
    
    

}



