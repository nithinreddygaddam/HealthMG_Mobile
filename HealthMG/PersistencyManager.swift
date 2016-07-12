//
//  PersistencyManager.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/7/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

class PersistencyManager: NSObject {
    
    private var subscribers = [User]()
    private var publishers = [User]()
    private var requests = [User]()
    
    func getPublishers() -> [User]{
        return publishers
    }
    
    func addPublisher(user: User){
        publishers.append(user)
    }
    
    func deletePublisherAtIndex(index: Int){
        publishers.removeAtIndex(index)
    }
    
    func getSubscribers() -> [User]{
        return subscribers
    }
    
    func deleteSubscriberAtIndex(index: Int){
        subscribers.removeAtIndex(index)
    }
    
    func getRequests() -> [User]{
        return requests
    }
    
    func AtIndex(index: Int){
        subscribers.removeAtIndex(index)
    }
}
