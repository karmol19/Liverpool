//
//  ProductSearchServiceObject.swift
//  Demo
//
//  Created by Carlos Molina on 05/09/18.
//  Copyright © 2018 Carlos Molina. All rights reserved.
//

import Foundation

class ProductSearchServiceObject:ServiceObject
{
    var search:Search!
    public init(search:Search)
    {
        super.init()
        self.search = search
        urlService = "\(pathUrlService.description)?s=\(search.title ?? "")&\(URLServiceObject.tokenService)=\(URLServiceObject.formatResponse)"
        urlService = urlService.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        typePetition = ServicePetition.get
    }
    
    override func startDownload(completionBlock: @escaping ([String : Any]?, Error?) -> Void)
    {
        super.startDownload(completionBlock: completionBlock)
        
    }
    
    override func parseJsonResponse(json: [String : Any]?, error: Error?)
    {
        super.parseJsonResponse(json: json, error: error)
        if error == nil
        {
            let privateContext = DataBaseManager.sharedInstance.privateObjectContext()
            privateContext.perform {
//                parse items
                if json?["contents"] != nil
                {
                    for jsonContent in (json?["contents"] as? [[String: Any]])!
                    {
                        if jsonContent["mainContent"] != nil
                        {
                            for jsonMainContent in (jsonContent["mainContent"] as? [[String: Any]])!
                            {
                                if jsonMainContent["contents"] != nil
                                {
                                    for jsonRecord in (jsonMainContent["contents"] as? [[String: Any]])!
                                    {
                                        if jsonRecord["records"] != nil
                                        {
                                            for jsonProduct in (jsonRecord["records"] as? [[String: Any]])!
                                            {
                                                var jsonAttributes = jsonProduct["attributes"] as! [String: Any]
                                                let productId = jsonAttributes["product.repositoryId"] as! Array<String>
                                                var product = DataBaseManager.sharedInstance.object(predicate:NSPredicate(format:"idProduct == %@",productId.first!), entity: DataBaseEntity.Product, context: privateContext) as? Product
                                                if product == nil
                                                {
                                                    product = Product.init(entity: DataBaseManager.sharedInstance.entityDescription(entityName: DataBaseEntity.Product)!, insertInto: privateContext)
                                                    product?.idProduct = productId.first!
                                                }
                                                product?.name =  (jsonAttributes["product.displayName"] as! Array<String>).first
                                                product?.image =  (jsonAttributes["sku.smallImage"] as! Array<String>).first
                                                product?.price =  Double((jsonAttributes["sku.list_Price"] as! Array<String>).first!)!
                                                let search = DataBaseManager.sharedInstance.object(predicate:NSPredicate(format:"title == %@",self.search.title!), entity: DataBaseEntity.Search, context: privateContext) as? Search
                                                product?.search = search

                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                DataBaseManager.sharedInstance.savePrivateContext(privateContext: privateContext)
                DataBaseManager.sharedInstance.saveContext(completionBlock: { (success, error) in
                    if self.customBlock != nil
                    {
                        self.customBlock!(json,error)
                    }
                })
                
            }
        }
        
    }
    
}
