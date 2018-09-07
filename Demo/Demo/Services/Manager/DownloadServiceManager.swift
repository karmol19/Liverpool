//
//  DownloadServiceManager.swift
//  Demo
//
//  Created by Carlos Molina on 05/09/18.
//  Copyright © 2018 Carlos Molina. All rights reserved.
//

import Foundation

class DownloadServiceManager {
    
    static let sharedInstance = DownloadServiceManager()
    private init() {}
    
    func downloadJsonRequest(serviceObject:ServiceObject)
    {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.timeoutIntervalForRequest = 30;
        sessionConfiguration.timeoutIntervalForResource = 60;
        let session =  URLSession(configuration: sessionConfiguration);
        let task = session.dataTask(with: URL(string: serviceObject.urlService)!) {
            data, response, error in
            
            if error == nil
            {
                let stringResponse = String.init(data: (data)!, encoding: String.Encoding.utf8)
                print("Response: ",stringResponse ?? "")
                let httpResponse = response as! HTTPURLResponse
                if httpResponse.statusCode == HTTPStatusCodes.OK.rawValue
                {
                    do {

                        let jsonDictionary = try JSONSerialization.jsonObject(with: data!, options:[])
                        serviceObject.parseJsonResponse(json: jsonDictionary as? [String : Any], error: nil)
                    }
                    catch let jsonErr {
                        serviceObject.parseJsonResponse(json: nil, error: jsonErr)
                    }
                   

                }
                else
                {
                    //Validate response code
                    var details = [String:Any]()
                    details.updateValue("Response code problem", forKey: NSLocalizedDescriptionKey)
                    let errorResponse = NSError(domain:"Response code problem", code:httpResponse.statusCode, userInfo:details)
                    serviceObject.parseJsonResponse(json: nil, error: errorResponse as Error)

                }
                
            }
            else
            {
                serviceObject.parseJsonResponse(json: nil, error: error)
            }
            
        }
        task.resume()
    }

}
