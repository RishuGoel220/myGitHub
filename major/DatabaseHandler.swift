
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
    
    
//---------------- Add the extra Stats for the conributor to database ------------------
    public func addContributorStats(repositoryName : String, contributorName : String, linesAdded : Int, linesDeleted : Int, commits : Int){
        
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
    
//------------------- Change Favourite Field in Database ---------------------------------
    
    public func changeIsFavouriteState(repositoryName : String){
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
    
    
//---------------- Remove User as Current User ------------------------
    public func changeCurrentUser(){
        
        let managedContext = appDelegate.managedObjectContext
        let managedObject = RepositoryViewController().currentUser()
        managedObject.setValue("no", forKey: "current")
        do{
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
    
//---------- Add User if not present otherwise update to current --------------
    public func addUser(username :String){
        
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