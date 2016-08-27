//
//  favouritesViewController.swift
//  major
//
//  Created by Rishu Goel on 16/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit
import CoreData
class favouritesViewController: UITableViewController {
    
    var repositories = [NSManagedObject] ()
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
    
    // MARK: Actions on the page
    
    // logout button press opens a alert and pressing yes on alert logs out
    @IBAction func logoutAction(sender: AnyObject) {
        let alert = UtilityHandler().showAlertWithSingleButton("Caution !", message: "Are you sure you want to Logout ?")
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { action in
            KeychainHandler().removeAuthToken()
            DatabaseHandler().changeCurrentUser()
            self.appDelegate.resetAppToFirstController()
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    @IBAction func favButtonClicked(sender: AnyObject) {
        let repositoryName = (self.repositories[sender.tag].valueForKey("repositoryName") as? String)!
        DatabaseHandler().changeIsFavouriteState(repositoryName)
        displayData()
    }
    
    // MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.92)
        displayData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.92)
         displayData()
    }
    
    // fetch repository and display data
    func displayData(){
        self.repositories = DatabaseHandler().fetchFavouriteRepositories()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellPrototype") as! repositoryCells
        // UI enhancement
        RepositoryViewController().setUpFavButtons(cell.favButton, row: indexPath.row)
        RepositoryViewController().makeBoundaryForView(cell.view)
        RepositoryViewController().makeImageCircular(cell.repositoryImage)
        
        // set favourite button
        if repositories[indexPath.row].valueForKey("isFavourite") as? String == "true"{
            cell.favButton.setImage(UIImage(named: "heartfilled"), forState: UIControlState.Normal)}
        else{
            cell.favButton.setImage(UIImage(named: "heartunfilled"), forState: UIControlState.Normal)}
        
        // Set Text Fields
        cell.repositoryName.text = repositories[indexPath.row].valueForKey("repositoryName") as? String
        cell.descriptionLabel.text = repositories[indexPath.row].valueForKey("descriptionRepo") as? String
        
        //  SET Image to the image view
        let URL = NSURL(string: (repositories[indexPath.row].valueForKey("avatarUrl") as? String)!)
        let placeholderImage = UIImage(named: "tabbutton")!
        cell.repositoryImage.contentMode = UIViewContentMode.ScaleAspectFit
        cell.repositoryImage
            .af_setImageWithURL(URL!, placeholderImage: placeholderImage)

        return cell

    }
    
    // passing data for the segue to next controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "RepositoryDescriptionScreen"
        {
            let destination = segue.destinationViewController as? RepositoryDetailsController,
            repositoryIndex = tableView.indexPathForSelectedRow?.row
            destination!.repositoryName  = (self.repositories[repositoryIndex!].valueForKey("repositoryName") as? String)!
        }
    }
}