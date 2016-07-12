//
//  SubscriptionAPI.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/7/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

class SubscriptionAPI: NSObject {
    
    private let persistencyManager: PersistencyManager
    //    private let httpClient: HTTPClient
    private let isOnline: Bool
    
    class var sharedInstance: SubscriptionAPI {
        
        struct Singleton {
            
            static let instance = SubscriptionAPI()
        }
        
        return Singleton.instance
    }
    
    override init() {
        persistencyManager = PersistencyManager()
        //        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
    }
    
    func getPublishers() -> [User]{
        return persistencyManager.getPublishers()
    }
    
    func addPublisher(user: User){
        persistencyManager.addPublisher(user)
        if isOnline{
            //            httpClient.postRequest("/api/addAlbum", body: album.description)
        }
    }
    
    func deletePublisher(index: Int){
        persistencyManager.deletePublisherAtIndex(index)
        if isOnline{
            //            httpClient.postRequest("/api/addAlbum", body: album.description)
        }
    }
    
    func getSubscribers() -> [User]{
        return persistencyManager.getSubscribers()
    }
    

    func deleteSubscriber(index: Int){
        persistencyManager.deleteSubscriberAtIndex(index)
        if isOnline{
            //            httpClient.postRequest("/api/addAlbum", body: album.description)
        }
    }


}
