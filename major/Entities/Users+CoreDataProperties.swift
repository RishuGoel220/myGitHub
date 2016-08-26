//
//  Users+CoreDataProperties.swift
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

extension Users {

    @NSManaged var current: String?
    @NSManaged var username: String?
    @NSManaged var repositories: NSSet?

}
