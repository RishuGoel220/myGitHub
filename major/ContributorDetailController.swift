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
                self.displaydata()
            }
            
        }
        
    }
    override func viewWillAppear(animated: Bool) {
        
        APIcaller().getContributorStats(repositoryName, username: self.username ){
            
            (responseBool)-> Void in
            if responseBool == true {
                super.viewWillAppear(animated)
                self.displaydata()
            }
            
        }
    }
    
    func displaydata(){
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Contributors")
        fetchRequest.predicate = NSPredicate(format: "contributorsName == %@ and repository.repositoryName == %@ ", contributorName, repositoryName)
        
        do {

            let contributors = try managedContext.executeFetchRequest(fetchRequest) as? [Contributors]
            
            if let currentContributor = contributors?.first {
                
                linesAddedLabel.text = "\(currentContributor.linesAdded!.integerValue)"
                linesDeletedLabel.text = "\(currentContributor.linesDeleted!.integerValue)"
                commitsLabel.text = "\(currentContributor.commits!.integerValue)"
                contributorNameLabel.text = currentContributor.contributorsName
                
                let placeholderImage = UIImage(named: "tabbutton.png")!
                contributorImage.contentMode = UIViewContentMode.ScaleAspectFit

                if let avatarURL = currentContributor.avatarUrl ,
                    let URL = NSURL(string: avatarURL) {
                    contributorImage.af_setImageWithURL(URL, placeholderImage: placeholderImage)
                } else {
                    contributorImage.image = placeholderImage
                }
                
            }
            
        }catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
}
