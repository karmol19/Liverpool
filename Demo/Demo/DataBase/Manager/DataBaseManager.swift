//
//  DataBaseManager.swift
//  Demo
//
//  Created by Carlos Molina on 04/09/18.
//  Copyright © 2018 Carlos Molina. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataBaseManager {
    
    static let sharedInstance = DataBaseManager()
    private var appDelegate:AppDelegate!
    public var mainContext:NSManagedObjectContext!
    private init()
    {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        mainContext = appDelegate.persistentContainer.viewContext
    }
    
    func privateObjectContext() -> NSManagedObjectContext
    {
        let privateContext = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = mainContext
        privateContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return privateContext;
    }
    
    func savePrivateContext(privateContext:NSManagedObjectContext)
    {
        guard privateContext.hasChanges else { return }
        
        do {
            try privateContext.save()
        } catch let error {
            print("\r error -> ",error.localizedDescription);
        }
    }
    
    func saveContext(completionBlock:(Bool,Error?) -> Void)
    {
        mainContext.performAndWait
        {
            guard mainContext.hasChanges else { completionBlock(true,nil); return}
            
            do {
                try mainContext.save()
                completionBlock(true,nil)
            } catch let error {
                print("\r error -> ",error.localizedDescription);
                completionBlock(false, error)
            }
            
        }
    }
    
    func delete(object:NSManagedObject)
    {
        mainContext.delete(object)
        saveContext()
    }
    
    func deleteAllObjects(entity:String)
    {
        let fetchEntity = self.fetchRequest(entity: entity)
        for object in fetchEntity!
        {
            mainContext.delete(object)
        }
        saveContext()
    }
    
    func saveContext()
    {
        appDelegate.saveContext()
    }
    
    
    func fetchRequest(entity:String) -> Array<NSManagedObject>?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entity)
        fetchRequest.includesSubentities = false
        return self.fetchRequest(fetchRequest:fetchRequest, context: mainContext)
        
    }
    
    func fetchRequest(fetchRequest:NSFetchRequest<NSFetchRequestResult>, context:NSManagedObjectContext) -> Array<NSManagedObject>?
    {
        do {
            return try context.fetch(fetchRequest) as? Array<NSManagedObject>
        } catch let error {
            print("\r error -> ",error.localizedDescription);
            
            return nil
        }
    }
    
    func fetchRequest(entity:String, predicate:NSPredicate) -> Array<NSManagedObject>?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entity)
        fetchRequest.includesSubentities = false
        fetchRequest.predicate = predicate
        return self.fetchRequest(fetchRequest:fetchRequest, context: mainContext)

    }
    
    func object(fetchRequest:NSFetchRequest<NSFetchRequestResult>, context:NSManagedObjectContext) -> NSManagedObject?
    {
        let result = self.fetchRequest(fetchRequest:fetchRequest, context: context)
        if (result?.count)! > 0
        {
            return result?.first
        }
        return nil

    }
    
    func object(fetchRequest:NSFetchRequest<NSFetchRequestResult>) -> NSManagedObject?
    {
        return object(fetchRequest: fetchRequest, context: mainContext)
    }
    
    
    func object(predicate:NSPredicate, entity:String) -> NSManagedObject?
    {
        return object(predicate: predicate, entity: entity, includeSubentities: true, context: mainContext)
    }
    
    
    func object(predicate:NSPredicate, entity:String, context: NSManagedObjectContext)->NSManagedObject?
    {
        return object(predicate: predicate, entity: entity, includeSubentities: true, context: context)
    }
    
    
    func object(predicate:NSPredicate, entity:String, includeSubentities:Bool) -> NSManagedObject? {
        return object(predicate: predicate, entity: entity, includeSubentities: includeSubentities, context: mainContext)
    }
    
    
    func object(predicate:NSPredicate, entity:String, includeSubentities:Bool, context:NSManagedObjectContext) -> NSManagedObject?
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: entity)
        fetchRequest.predicate = predicate
        fetchRequest.includesSubentities = includeSubentities
        return object(fetchRequest: fetchRequest, context: context)
    }
    
    
    func fetchReques(entity:String) -> Array<NSManagedObject>? {
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>.init(entityName: entity)
        fetchRequest.includesSubentities = false
        return self.fetchRequest(fetchRequest: fetchRequest, context: mainContext)
    }
    
    
    func entityDescription(entityName:String) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: entityName, in: mainContext)
    }
    
}
