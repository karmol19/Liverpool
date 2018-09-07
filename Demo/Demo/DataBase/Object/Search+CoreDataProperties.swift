//
//  Search+CoreDataProperties.swift
//  Demo
//
//  Created by Carlos Molina on 06/09/18.
//  Copyright © 2018 Carlos Molina. All rights reserved.
//
//

import Foundation
import CoreData


extension Search {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Search> {
        return NSFetchRequest<Search>(entityName: "Search")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var title: String?
    @NSManaged public var results: NSSet?

}

// MARK: Generated accessors for results
extension Search {

    @objc(addResultsObject:)
    @NSManaged public func addToResults(_ value: Product)

    @objc(removeResultsObject:)
    @NSManaged public func removeFromResults(_ value: Product)

    @objc(addResults:)
    @NSManaged public func addToResults(_ values: NSSet)

    @objc(removeResults:)
    @NSManaged public func removeFromResults(_ values: NSSet)

}
