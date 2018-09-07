//
//  ServiceObject.swift
//  Demo
//
//  Created by Carlos Molina on 05/09/18.
//  Copyright © 2018 Carlos Molina. All rights reserved.
//

import Foundation

class ServiceObject
{
    enum ServicePetition {
        case get
        case post
    }
    
    private enum Environment {
        case development
        case qa
        case production
    }
    
    var jsonRequest:[String: Any]?
    var typePetition:ServicePetition!
    var urlService:String!
    var pathUrlService:String!
    private var environmentToUse = Environment.development
    var customBlock:(([String: Any]?,Error?)->Void)?
    
    public init()
    {
        switch environmentToUse {
        case .development:
            self.pathUrlService = "https://www.liverpool.com.mx/tienda/"
            break
        case .qa:
            //            url qa here
            self.pathUrlService = ""
            break
        case .production:
            //            url production here
            self.pathUrlService = ""

            break
        }
        
    }
    
    func startDownload(completionBlock:@escaping ([String: Any]?,Error?) -> Void)
    {
        customBlock = completionBlock
        startDownload()
    }
    
    func startDownload()
    {
        switch typePetition {
        case .get:
            DownloadServiceManager.sharedInstance.downloadJsonRequest(serviceObject: self)
            break
        case .post:
            break

        default:
            break
            
        }
    }
    
    func parseJsonResponse(json:[String: Any]?,error:Error?)
    {
        if(error != nil)
        {
            OperationQueue.main.addOperation
            {
                if self.customBlock != nil
                {
                    self.customBlock!(json,error)
                }
                
            }
        }
        else
        {
//            parse generalData
        }
    }
    
}
