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

class ContributorDetailController: UIViewController {
    
//----------------- views on the page -----------------------
    @IBOutlet weak var commitsLabel: UILabel!
    @IBOutlet weak var linesDeletedLabel: UILabel!
    @IBOutlet weak var linesAddedLabel: UILabel!
    @IBOutlet weak var contributorNameLabel: UILabel!
    @IBOutlet weak var contributorImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var fixedCommitsLabel: UILabel!
    @IBOutlet weak var fixedLinesDeletedLabel: UILabel!
    @IBOutlet weak var fixedLinesAddedLabel: UILabel!

//----------- Global variables to store data ---------------
    var repositoryName = ""
    var contributorName = ""
    var contributor = [NSManagedObject]()
    var username = DatabaseHandler().currentUser().valueForKey("username") as! String
    
    
    override func viewDidLoad() {
        
        APIcaller().getContributorStats(repositoryName, username: self.username ){
            (responseBool)-> Void in
            
            if responseBool == true {
                super.viewDidLoad()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.showLabels()
                self.displaydata()
                
            }
            if responseBool == false {
                super.viewDidLoad()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.showAlertNoResponse()
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.startAnimating()
        hideLabels()
    
    }
    
    func showAlertNoResponse() {
        let alert = UtilityHandler().showAlertWithSingleButton("Caution!", message: "There might be some issue with the internet ")
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func hideLabels(){
        contributorNameLabel.hidden = true
        fixedCommitsLabel.hidden = true
        fixedLinesAddedLabel.hidden = true
        fixedLinesDeletedLabel.hidden = true
        
    }
    
    func showLabels(){
        self.contributorNameLabel.hidden = false
        self.fixedCommitsLabel.hidden = false
        self.fixedLinesAddedLabel.hidden = false
        self.fixedLinesDeletedLabel.hidden = false
    }
    
    func displaydata(){
                let currentContributor = DatabaseHandler().fetchContributorByName(contributorName, repositoryName: repositoryName).first!
                linesAddedLabel.text = "\(currentContributor.linesAdded!.integerValue)"
                linesDeletedLabel.text = "\(currentContributor.linesDeleted!.integerValue)"
                commitsLabel.text = "\(currentContributor.commits!.integerValue)"
                contributorNameLabel.text = currentContributor.contributorsName
                
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
