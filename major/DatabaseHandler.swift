
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
    
    
    
    public func addContributorStats(repositoryName : String, contributorName : String, linesAdded : Int, linesDeleted : Int, commits : Int){
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Repositories")
        fetchRequest.predicate = NSPredicate(format: "repositoryName == %@ and users CONTAINS %@",repositoryName, self.currentUser())
        
        do {
            
                let results =
                    try managedContext.executeFetchRequest(fetchRequest)
                
                // check for duplicate
                
                let fetchRequest = NSFetchRequest(entityName: "Contributors")
                fetchRequest.predicate = NSPredicate(format: "contributorsName == %@ and repository == %@ ", contributorName, results[0] as! NSManagedObject)
                let fetchResults =
                    try managedContext.executeFetchRequest(fetchRequest)
                if fetchResults.count != 0{
                    fetchResults[0].setValue(linesAdded, forKey: "linesAdded")
                    fetchResults[0].setValue(linesDeleted, forKey: "linesDeleted")
                    fetchResults[0].setValue(commits, forKey: "commits")
                    try managedContext.save()
                }
                
            }catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }        
    }
    
    public func changeIsFavouriteState(repositoryName : String){
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Repositories")
        fetchRequest.predicate = NSPredicate(format: "repositoryName = %@ and users CONTAINS %@",repositoryName, self.currentUser())
        
        
        do {
            let fetchResults =
                try appDelegate.managedObjectContext.executeFetchRequest(fetchRequest)
            if fetchResults.count != 0{
                
                let managedObject = fetchResults[0]
                let boolvalue = fetchResults[0].valueForKey("isFavourite") as? String
                if boolvalue=="false" {
                    managedObject.setValue("true", forKey: "isFavourite")
                }
                else{
                    managedObject.setValue("false", forKey: "isFavourite")
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
            let fetchResults =
                try managedContext.executeFetchRequest(fetchRequest)
            if fetchResults.count != 0{
                let managedObject = fetchResults[0]
                managedObject.setValue("yes", forKey: "current")
                try managedContext.save()
                return
            }
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        let entity =  NSEntityDescription.entityForName("Users",inManagedObjectContext:managedContext)
        let user = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        user.setValue(username, forKey: "username")
        user.setValue("yes", forKey: "current")
        
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    
    }
    
    
    func currentUser()-> NSManagedObject{
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "Users")
        fetchRequest.predicate = NSPredicate(format: "current = \"yes\"")
        
        do {
            let fetchResults =
                try managedContext.executeFetchRequest(fetchRequest)
            let managedObject = fetchResults[0]
            return managedObject as! NSManagedObject
            
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        let dummy = NSManagedObject()
        return dummy
    }



}