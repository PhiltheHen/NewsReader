//
//  NRStoryMO+CoreDataProperties.swift
//  NewsReader
//
//  Created by Philip Henson on 12/13/15.
//  Copyright © 2015 Phil Henson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension NRStoryMO {

    @NSManaged var link: String?
    @NSManaged var pubDate: NSDate?
    @NSManaged var textDescription: String?
    @NSManaged var title: String?

}
