//
//  Product+CoreDataProperties.swift
//  Demo
//
//  Created by Carlos Molina on 06/09/18.
//  Copyright © 2018 Carlos Molina. All rights reserved.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var idProduct: String?
    @NSManaged public var image: String?
    @NSManaged public var name: String?
    @NSManaged public var price: Double
    @NSManaged public var promoPrice: Double
    @NSManaged public var rating: Int16
    @NSManaged public var search: Search?

}
