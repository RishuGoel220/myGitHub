//
//  Contributors+CoreDataProperties.swift
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

extension Contributors {

    @NSManaged var avatarUrl: String?
    @NSManaged var contributions: String?
    @NSManaged var contributorsName: String?
    @NSManaged var linesAdded: NSNumber?
    @NSManaged var linesDeleted: NSNumber?
    @NSManaged var commits: NSNumber?
    @NSManaged var repository: Repositories?

}
