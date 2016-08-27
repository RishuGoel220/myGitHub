
//
//  DatabaseHandler.swift
//  major
//
//  Created by Rishu Goel on 24/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import Foundation
import SystemConfiguration
import CoreData
import UIKit

//------------------------------------------------------------------------------
// DESCRIPTION: Class to access Core Data contains fetching, updating and adding
//              data to core data
//------------------------------------------------------------------------------
public class DatabaseHandler {
    
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate

    
    
// MARK: Repository Data Handling functions
    
//------------------------------------------------------------------------------
// DESCRIPTION: function to fetch repositories marked as favourite 
//              returns an array of Onbject of Type Repository Managed Object
//------------------------------------------------------------------------------
    func fetchFavouriteRepositories()-> [Repositories]{
        let managedContext = appDelegate.managedObjectContext
        
    // To be fetched from table Repositories
        let fetchRequest = NSFetchRequest(entityName: "Repositories")
        
    // Repository which is marked as favourite and for Current User
        let predicate = "isFavourite == %@ and users CONTAINS %@"
        fetchRequest.predicate = NSPredicate(format: predicate , "true",
                                             DatabaseHandler().currentUser())
        
        do {
            let repositories =
                try managedContext.executeFetchRequest(fetchRequest) as! [Repositories]
            return repositories
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
    // if there is some error with fetching print error and return empty array
        return []
    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: function to fetch repositories by its name
//              returns an array of Object of Type Repository Managed Object
//------------------------------------------------------------------------------
    func fetchRepositoryByName(repositoryName : String)-> [Repositories]{
        let managedContext = appDelegate.managedObjectContext
        do {
            let fetchRequest = NSFetchRequest(entityName: "Repositories")
            
            // Search for repository by name adn where user is current active user
            let predicate = "repositoryName == %@ and users CONTAINS %@"
            fetchRequest.predicate = NSPredicate(format: predicate, repositoryName,
                                                 DatabaseHandler().currentUser())
            
            let repositories =
                try managedContext.executeFetchRequest(fetchRequest) as! [Repositories]
            return repositories
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
    // if there is some error with fetching print error and return empty array
        return []
    }

//------------------------------------------------------------------------------
// DESCRIPTION: function to fetch All repositories for the current user
//              returns an array of Object of Type Repository Managed Object
//------------------------------------------------------------------------------
    func fetchAllRepositories()-> [Repositories]{
        let managedContext = appDelegate.managedObjectContext
        do {
            let fetchRequest = NSFetchRequest(entityName: "Repositories")
            
        // Fetch all repositories where user is currently active user
            fetchRequest.predicate = NSPredicate(format: "users CONTAINS %@",
                                                 DatabaseHandler().currentUser())
            let repositories =
                try managedContext.executeFetchRequest(fetchRequest) as! [Repositories]
            return repositories
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
    // if there is some error with fetching print error and return empty array
        return []
    }

//------------------------------------------------------------------------------
// DESCRIPTION: function to Add new repository to the Database
//------------------------------------------------------------------------------
    func AddNewRepository(repositoryName: String, isFavourite: String,
                          description: String, Url: String){
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Repositories",
                                                        inManagedObjectContext:managedContext)
        let repository = NSManagedObject(entity: entity!,
                                   insertIntoManagedObjectContext: managedContext) as! Repositories
        
        
    // Set the values passed to the function to the new repository Object
        repository.repositoryName = repositoryName
        repository.isFavourite = isFavourite
        repository.descriptionRepo = description
        repository.avatarUrl = Url
    // Make the relationship with the current user by passing its object
        repository.users = NSSet(object : DatabaseHandler().currentUser())
        
    // Add it to the persistent store by saving
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: function to Update the repository to the Database
//------------------------------------------------------------------------------
    func updateExistingRepository(repositoryName : String, Url: String, description: String){
        let managedContext = appDelegate.managedObjectContext
        do{
        // Search the repository by its name in the database
            let repositories = DatabaseHandler().fetchRepositoryByName(repositoryName)
            let repository = repositories.first
        // Update its Data and Save it in the database
            repository!.avatarUrl = Url
            repository!.descriptionRepo = description
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    
//------------------------------------------------------------------------------
// DESCRIPTION: function to Add PR count to the repository Object in Database
//------------------------------------------------------------------------------
    func addPRCount(repositoryName : String, username: String, PR: [Int] ){
        let managedContext = self.appDelegate.managedObjectContext
            do {
            // fetch the repository by its name
                let fetchResultsWithUser = DatabaseHandler().fetchRepositoryByName(repositoryName)
            // Now update the repository PR counts and save
                if fetchResultsWithUser.count != 0{
                    fetchResultsWithUser[0].setValue(PR[0], forKey: "openPR")
                    fetchResultsWithUser[0].setValue(PR[1], forKey: "mergedPR")
                    try managedContext.save()
                }
                
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            
    }

//------------------------------------------------------------------------------
// DESCRIPTION: function to Add Issue count to the repository Object in Database
//------------------------------------------------------------------------------
    func addIssueCount(repositoryName : String, username: String, Issues: [Int]){
        let managedContext = self.appDelegate.managedObjectContext
            do {
            // fetch the repository by its name
                let fetchResultsWithUser = DatabaseHandler().fetchRepositoryByName(repositoryName)
            // Now update the repository Issue counts and save
                if fetchResultsWithUser.count != 0{
                    fetchResultsWithUser[0].setValue(Issues[0], forKey: "openIssues")
                    fetchResultsWithUser[0].setValue(Issues[1], forKey: "closedIssues")
                    try managedContext.save()
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
        
    }
    
    
    

// MARK: Contributors Data Handling functions
    
//------------------------------------------------------------------------------
// DESCRIPTION: function to fetch All contributor for the current user and the
//              given repository.
//              returns an array of Object of Type Contributor Managed Object
//------------------------------------------------------------------------------
    func fetchAllContributors(repositoryName: String)-> [Contributors]{
        let managedContext = appDelegate.managedObjectContext
        do {
        // To be fetched from table Contributors
            let fetchRequest = NSFetchRequest(entityName: "Contributors")
            
        // fetch repository for the active user and search all contributor
        // associated with it
            fetchRequest.predicate = NSPredicate(format: "repository == %@",
                                                 self.fetchRepositoryByName(repositoryName).first!)
            let contributors =
                try managedContext.executeFetchRequest(fetchRequest) as! [Contributors]
            return contributors
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return []
    }

    
//------------------------------------------------------------------------------
// DESCRIPTION: function to Add New Contributor
//------------------------------------------------------------------------------
    func AddNewContributor(contributorName: String, repositoryName: String,
                           contributions: String, Url: String ){
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Contributors",
                                                        inManagedObjectContext:managedContext)
        let contributor = NSManagedObject(entity: entity!,
                                         insertIntoManagedObjectContext: managedContext) as! Contributors
        
        // Add the data of contributor to contributor object and Save to Database
        contributor.repository = DatabaseHandler().fetchRepositoryByName(repositoryName).first
        contributor.contributorsName = contributorName
        contributor.contributions = contributions
        contributor.avatarUrl = Url
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: function to Update Existing Contributor
//------------------------------------------------------------------------------
    func updateExistingContributor(contributorName: String, repositoryName : String,
                                   Url: String, contributions: String){
        let managedContext = appDelegate.managedObjectContext
        do{
        // Fetch contributor Object for by its name and repository Name
            let contributors = DatabaseHandler().fetchContributorByName(contributorName,
                                                                        repositoryName: repositoryName)
            let contributor = contributors.first
            
        // update the contributor details and save to database
            contributor!.avatarUrl = Url
            contributor!.contributions = contributions
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: function to fetch contributor by its name for the current user
//              and given repository
//              returns an array of Object of Type Contributors Managed Object
//------------------------------------------------------------------------------
    func fetchContributorByName(contributorName: String, repositoryName : String)-> [Contributors]{
        let managedContext = appDelegate.managedObjectContext
        do {
            let fetchRequest = NSFetchRequest(entityName: "Contributors")
            let predicate = "contributorsName == %@ and repository == %@ "
            
            fetchRequest.predicate = NSPredicate(format: predicate,contributorName,
                                                 self.fetchRepositoryByName(repositoryName).first!)
            let contributors =
                try managedContext.executeFetchRequest(fetchRequest) as! [Contributors]
            return contributors
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return []
    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: function to Add Extra Contributor details for a contributor Name
//              in Database
//------------------------------------------------------------------------------
    func addContributorStats(repositoryName : String, contributorName : String,
                             linesAdded : Int, linesDeleted : Int, commits : Int){
        let managedContext = appDelegate.managedObjectContext
        do {
        // search for contributor by its name and repositry Name for current User
            let contributors = self.fetchContributorByName(contributorName,
                                                               repositoryName: repositoryName)
        // add extra details for the user and save
            if let contributor = contributors.first{
                contributor.linesAdded = linesAdded
                contributor.linesDeleted = linesDeleted
                contributor.commits = commits
                try managedContext.save()
            }
                
        }catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }        
    }
    
// MARK: Favourite Handling
    
//------------------------------------------------------------------------------
// DESCRIPTION: function to change the favourite State for the given repository
//              in Database
//------------------------------------------------------------------------------
    func changeIsFavouriteState(repositoryName : String){
        
        let managedContext = appDelegate.managedObjectContext
        do {
        // fetch repository fo the given name
            let repository = self.fetchRepositoryByName(repositoryName)
            if let currentRepository = repository.first{
        // change the is Favoutrite stae depeneding on previous state
                let boolvalue = "\(currentRepository.isFavourite!)"
                if boolvalue == "false" {
                    currentRepository.isFavourite = "true"
                }
                else{
                    currentRepository.isFavourite = "false"
                }
                try managedContext.save()
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
    
// MARK: User data Functions
//------------------------------------------------------------------------------
// DESCRIPTION: Function to make the current User inactive
//------------------------------------------------------------------------------
    func changeCurrentUser(){
        
        let managedContext = appDelegate.managedObjectContext
        let managedObject = DatabaseHandler().currentUser()
        
        managedObject.setValue("no", forKey: "current")
        do{
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: Function to add New User to database
//------------------------------------------------------------------------------
    func addUser(username :String){
        
        // search for user for existing username
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Users")
        fetchRequest.predicate = NSPredicate(format: "username = %@", username)

        do {
            let users =
                try managedContext.executeFetchRequest(fetchRequest) as? [Users]
        // If user doesnt exist create a user
            guard let user = users?.first where users?.count > 0 else{
                // Add new user if user doesnt exist
                let entity =  NSEntityDescription.entityForName("Users",inManagedObjectContext:managedContext)
                let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                user.setValue(username, forKey: "username")
                user.setValue("yes", forKey: "current")
                try managedContext.save()
                return
            }
        // if user exist set it to current User
            user.current = "yes"
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    
    }
    
    
//------------------------------------------------------------------------------
// DESCRIPTION: Function to return the current active User
//------------------------------------------------------------------------------
    func currentUser()-> NSManagedObject{
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Users")
        fetchRequest.predicate = NSPredicate(format: "current = \"yes\"")
        
        do {
            let user =
                try managedContext.executeFetchRequest(fetchRequest) as? [Users]
            let currentUser = user?.first
            return currentUser!
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        let dummy = NSManagedObject()
        return dummy
    }

}