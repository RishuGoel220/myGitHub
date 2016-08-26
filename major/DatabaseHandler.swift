
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

public class DatabaseHandler {
    
    let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate

// MARK: Repository Data Handling functions
//---------------- Repository Database functions ------------------
    func fetchFavouriteRepositories()-> [Repositories]{
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Repositories")
        fetchRequest.predicate = NSPredicate(format: "isFavourite == %@ and users CONTAINS %@", "true", DatabaseHandler().currentUser())
        do {
            let repositories =
                try managedContext.executeFetchRequest(fetchRequest) as! [Repositories]
            return repositories
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return []
    }
    
    
    func fetchAllRepositories()-> [Repositories]{
        let managedContext = appDelegate.managedObjectContext
        do {
            let fetchRequest = NSFetchRequest(entityName: "Repositories")
            fetchRequest.predicate = NSPredicate(format: "users CONTAINS %@", DatabaseHandler().currentUser())
            let repositories =
                try managedContext.executeFetchRequest(fetchRequest) as! [Repositories]
            return repositories
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return []
    }
    
    func AddNewRepository(repositoryName: String, isFavourite: String, description: String, Url: String ){
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entityForName("Repositories",
                                                        inManagedObjectContext:managedContext)
        let repository = NSManagedObject(entity: entity!,
                                   insertIntoManagedObjectContext: managedContext) as! Repositories
        
        repository.repositoryName = repositoryName
        repository.isFavourite = isFavourite
        repository.descriptionRepo = description
        repository.avatarUrl = Url
        repository.users = NSSet(object : DatabaseHandler().currentUser())
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    
    
    func updateExistingRepository(repositoryName : String, Url: String, description: String){
        let managedContext = appDelegate.managedObjectContext
        do{
            let repositories = DatabaseHandler().fetchRepositoryByName(repositoryName)
            let repository = repositories.first
            repository!.avatarUrl = Url
            repository!.descriptionRepo = description
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    func fetchRepositoryByName(repositoryName : String)-> [Repositories]{
        let managedContext = appDelegate.managedObjectContext
        do {
            let fetchRequest = NSFetchRequest(entityName: "Repositories")
            fetchRequest.predicate = NSPredicate(format: "repositoryName == %@ and users CONTAINS %@", repositoryName, DatabaseHandler().currentUser())
            let repositories =
                try managedContext.executeFetchRequest(fetchRequest) as! [Repositories]
            return repositories
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return []
    }
    //---------------- Add the repo extra stats------------------
    func addRepositoryStats(repositoryName : String, username: String){
        let managedContext = self.appDelegate.managedObjectContext
        APIcaller().getPRCount(repositoryName, username : username){
            (PR: [Int])-> Void in
            do {
                
                let fetchRequest = NSFetchRequest(entityName: "Repositories")
                fetchRequest.predicate = NSPredicate(format: "repositoryName = %@ and users CONTAINS %@", repositoryName, DatabaseHandler().currentUser())
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
                fetchRequest.predicate = NSPredicate(format: "repositoryName = %@ and users CONTAINS %@",repositoryName, DatabaseHandler().currentUser())
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
    
    
    

// MARK: Contributors Data Handling functions
//---------------- Contributors Database functions ------------------
    func fetchAllContributors(repositoryName: String)-> [Contributors]{
        let managedContext = appDelegate.managedObjectContext
        do {
            let fetchRequest = NSFetchRequest(entityName: "Contributors")
            fetchRequest.predicate = NSPredicate(format: "repository == %@", DatabaseHandler().fetchRepositoryByName(repositoryName).first!)
            let contributors =
                try managedContext.executeFetchRequest(fetchRequest) as! [Contributors]
            return contributors
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return []
    }
    
    func AddNewContributor(contributorName: String, repositoryName: String, contributions: String, Url: String ){
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Contributors",
                                                        inManagedObjectContext:managedContext)
        let contributor = NSManagedObject(entity: entity!,
                                         insertIntoManagedObjectContext: managedContext) as! Contributors
        
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
    
    
    func updateExistingContributor(contributorName: String, repositoryName : String, Url: String, contributions: String){
        let managedContext = appDelegate.managedObjectContext
        do{
            let contributors = DatabaseHandler().fetchContributorByName(contributorName, repositoryName: repositoryName)
            let contributor = contributors.first
            contributor!.avatarUrl = Url
            contributor!.contributions = contributions
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func fetchContributorByName(contributorName: String, repositoryName : String)-> [Contributors]{
        let managedContext = appDelegate.managedObjectContext
        do {
            let fetchRequest = NSFetchRequest(entityName: "Contributors")
            fetchRequest.predicate = NSPredicate(format: "contributorsName == %@ and repository == %@ ",contributorName,self.fetchRepositoryByName(repositoryName).first!)
            let contributors =
                try managedContext.executeFetchRequest(fetchRequest) as! [Contributors]
            return contributors
        }catch let error as NSError{
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return []
    }
    

    
//---------------- Add the extra Stats for the conributor to database ------------------
    func addContributorStats(repositoryName : String, contributorName : String, linesAdded : Int, linesDeleted : Int, commits : Int){
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Repositories")
        fetchRequest.predicate = NSPredicate(format: "repositoryName == %@ and users CONTAINS %@",repositoryName, self.currentUser())
        
        do {
            
                let repositories = try managedContext.executeFetchRequest(fetchRequest) as? [Repositories]
                
                // check for duplicate
                
                let fetchRequest = NSFetchRequest(entityName: "Contributors")
                fetchRequest.predicate = NSPredicate(format: "contributorsName == %@ and repository == %@ ", contributorName, (repositories?.first)!)
                let contributors =
                    try managedContext.executeFetchRequest(fetchRequest) as? [Contributors]
                if let contributor = contributors?.first{
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
//------------------- Change Favourite Field in Database ---------------------------------
    
    func changeIsFavouriteState(repositoryName : String){
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Repositories")
        fetchRequest.predicate = NSPredicate(format: "repositoryName = %@ and users CONTAINS %@",repositoryName, self.currentUser())
        
        
        do {
            let repository =
                try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest) as? [Repositories]
            if let currentRepository = repository?.first{
                
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
//---------------- Remove User as Current User ------------------------
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
    
//---------- Add User if not present otherwise update to current --------------
    func addUser(username :String){
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Users")
        fetchRequest.predicate = NSPredicate(format: "username = %@", username)

        do {
            let users =
                try managedContext.executeFetchRequest(fetchRequest) as? [Users]
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
    
//-------------------- Give the object of current User -----------------------------
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