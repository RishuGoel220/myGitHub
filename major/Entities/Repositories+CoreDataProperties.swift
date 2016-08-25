//
//  Repositories+CoreDataProperties.swift
//  major
//
//  Created by Rishu Goel on 25/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Repositories {

    @NSManaged var avatarUrl: String?
    @NSManaged var closedIssues: NSNumber?
    @NSManaged var descriptionRepo: String?
    @NSManaged var isFavourite: String?
    @NSManaged var mergedPR: NSNumber?
    @NSManaged var openIssues: NSNumber?
    @NSManaged var openPR: NSNumber?
    @NSManaged var repositoryName: String?
    @NSManaged var contributors: NSSet?
    @NSManaged var users: NSSet?

}
