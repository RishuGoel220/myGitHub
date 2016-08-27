//
//  ContributorDetailController.swift
//  major
//
//  Created by Rishu Goel on 25/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit
import AlamofireImage
import CoreData

//------------------------------------------------------------------------------
// DESCRIPTION: This is the Controller for the screen of contributor Details for
//              particular repository. 
//------------------------------------------------------------------------------
class ContributorDetailController: UIViewController {

// MARK: Views on Screen

//------------------------------------------------------------------------------
// Description: These are the various views on the screen
//------------------------------------------------------------------------------
    @IBOutlet weak var commitsLabel: UILabel!
    @IBOutlet weak var linesDeletedLabel: UILabel!
    @IBOutlet weak var linesAddedLabel: UILabel!
    @IBOutlet weak var contributorNameLabel: UILabel!
    @IBOutlet weak var contributorImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // These labels are static and doesnt change in program
    @IBOutlet weak var fixedCommitsLabel: UILabel!
    @IBOutlet weak var fixedLinesDeletedLabel: UILabel!
    @IBOutlet weak var fixedLinesAddedLabel: UILabel!

    //----------- Global variables to store data ---------------
    var repositoryName = ""
    var contributorName = ""
    var contributor = [NSManagedObject]()
    var username = DatabaseHandler().currentUser().valueForKey("username") as! String

// MARK: view functions
// View function
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    // Start the activity indicator for showing loading status
        activityIndicator.startAnimating()
    // To hide any content before data is fetched
        hideLabels()
    }
    
    override func viewDidLoad() {
        dataHandler().getContributorStats(repositoryName, username: self.username ){
            (responseBool)-> Void in
            // if the data is fetched and added we render the page
            if responseBool == true {
                super.viewDidLoad()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.showLabels()
                self.displaydata()
                
            }
            if responseBool == false {
            // Stop indicator and show a alert stating data could not pe fetched
                super.viewDidLoad()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.showAlertNoResponse()
            }
            
        }
        
    }
    
    
// function to call the alert for error in fetching contributor details
    func showAlertNoResponse() {
        let alert = UtilityHandler().showAlertWithSingleButton("Caution!", message: "There might be some issue with the internet ")
        self.presentViewController(alert, animated: true, completion: nil)
    }
// function to hide labels
    func hideLabels(){
        contributorNameLabel.hidden = true
        fixedCommitsLabel.hidden = true
        fixedLinesAddedLabel.hidden = true
        fixedLinesDeletedLabel.hidden = true
    }
    
// function to show labels
    func showLabels(){
        self.contributorNameLabel.hidden = false
        self.fixedCommitsLabel.hidden = false
        self.fixedLinesAddedLabel.hidden = false
        self.fixedLinesDeletedLabel.hidden = false
    }

// function to display the dta by fetching from database
    func displaydata(){
        // fetch contributor whose page is opened for tthe given repository
        let currentContributor = DatabaseHandler().fetchContributorByName(contributorName, repositoryName: repositoryName).first!
        
        // fill data in labels
        linesAddedLabel.text = "\(currentContributor.linesAdded!.integerValue)"
        linesDeletedLabel.text = "\(currentContributor.linesDeleted!.integerValue)"
        commitsLabel.text = "\(currentContributor.commits!.integerValue)"
        contributorNameLabel.text = currentContributor.contributorsName
        
        // put contributor image async
        let placeholderImage = UIImage(named: "tabbutton")!
        contributorImage.contentMode = UIViewContentMode.ScaleAspectFit
        if let avatarURL = currentContributor.avatarUrl ,
            let URL = NSURL(string: avatarURL) {
            contributorImage.af_setImageWithURL(URL, placeholderImage: placeholderImage)
        } else {
            contributorImage.image = placeholderImage
        }
    
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
}
