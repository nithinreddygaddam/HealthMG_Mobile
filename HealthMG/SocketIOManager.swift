//
//  SocketManager.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/5/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import SocketIOClientSwift
import SimpleKeychain
import SwiftyJSON

var connected : Bool = false
//var available : Bool = false

class SocketIOManager: NSObject {
    
    //Singleton
    static let sharedInstance = SocketIOManager()
    
    //retrieve saved token
    let jwt = A0SimpleKeychain().stringForKey("user-jwt") as String!
    
    lazy var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://10.0.0.13:8100" )!, options: [.Log(true), .ConnectParams(["token": self.jwt]) ])

    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
        
        if connected == false{
            socket.emit("newUser",loggedUser.id!)
            
            socket.on("connected") {data, ack in
                self.socket.emit("newUser",loggedUser.id!)
                connected = true
                print("socket connected")
            }
        }
    }
    
    func closeConnection() {
        if connected == true{
            socket.disconnect()
            
            //delete the token in store
            A0SimpleKeychain().deleteEntryForKey("user-jwt")
            connected = false
        }
    }
    
//    func checkConnection( completionHandler: (available: bool) -> Void) {
//        
//        socket.emit("ping")
//        
//        socket.on("pong") { ( dataArray, ack) -> Void in
//            
//            completionHandler(available: true )
//            
//        }
//    }
    
    func sendHeartRate(timeStamp: String, date: String, time:String, hr: String, uuid: String, publisher: String) {
        socket.emit("heartRate", timeStamp, date, time, hr, uuid, publisher)
    }
    
    func sendStepCount(timeStamp: String, date: String, time:String, count: String, uuid: String, publisher: String) {
        socket.emit("stepCount", timeStamp, date, time, count, uuid, publisher)
    }
    
    func sendDistance(timeStamp: String, date: String, time:String, distance: String, uuid: String, publisher: String) {
        socket.emit("distance", timeStamp, date, time, distance, uuid, publisher)
    }
    
    func sendCalories(timeStamp: String, date: String, time:String, calories: String, uuid: String, publisher: String) {
        socket.emit("calories", timeStamp, date, time, calories, uuid, publisher)
    }
    
    func getLatestRecords(user: [String: AnyObject], completionHandler: (latestRecords: [[String: AnyObject]]?) -> Void) {
        
        socket.emit("getLatestRecords", user)
        
        socket.on("successLatestRecords") { ( dataArray, ack) -> Void in
            let flag = dataArray[1]
            if (flag as! NSObject == 0){
                completionHandler(latestRecords: dataArray[0] as? [[String: AnyObject]])
            }
            else{
                //garbage values
                completionHandler(latestRecords: [[ "dob": 20, "lastName": 3]])
            }
        }
        
        socket.on("error") { (dataArray, socketAck) -> Void in
        }
    }
    
    func getPublishers(userID: String?, completionHandler: (publishers: [[String: AnyObject]]?) -> Void) {
        
        socket.emit("getPublishersList", userID!)
        
        socket.on("successPubList") { ( dataArray, ack) -> Void in
            
            completionHandler(publishers: dataArray[0] as? [[String: AnyObject]] )
            
        }
    }
    
    func getSubscribers(userID: String?, completionHandler: (subscribers: [[String: AnyObject]]?) -> Void) {
        
        socket.emit("getSubscribersList", userID!)
        
        socket.on("successSubList") { ( dataArray, ack) -> Void in
            
            completionHandler(subscribers: dataArray[0] as? [[String: AnyObject]] )
            
        }
    }
    
    func deletePublisher(userID: String?, publisher: [String: AnyObject]) {
        socket.emit("deleteSubcribtion", userID!, publisher)
    }
    
    func deleteSubscriber(userID: String?, subscriber: [String: AnyObject]) {
        socket.emit("deleteSubcribtion", subscriber, userID!)
    }
    
    func getChats(userID: String?, completionHandler: (chatsList: [[String: AnyObject]]!, lastMsg: [[String: AnyObject]]?) -> Void) {
        
        socket.emit("getChastList", userID!)
        
        socket.on("successChatsList") { ( dataArray, ack) -> Void in
            
            completionHandler(chatsList: dataArray[0] as? [[String: AnyObject]], lastMsg: dataArray[1] as? [[String: AnyObject]] )
            
        }
    }
    
    func deleteChat(conversationID: String?) {
        socket.emit("deleteChat", conversationID!)
    }
    
    func getConversation(conversationID: String?, completionHandler: (chat: [[String: AnyObject]]?) -> Void) {
        
        socket.emit("getConversation", conversationID!)
        
        socket.on("successConversation") { ( dataArray, ack) -> Void in
            
            completionHandler(chat: dataArray[0] as? [[String: AnyObject]] )
            
        }
    }
    
    func getUser(userID: String?, completionHandler: (user: [String: AnyObject]!, permissions: [String: AnyObject]?) -> Void) {
        
        socket.emit("getUser", userID!)
        
        socket.on("successUser") { ( dataArray, ack) -> Void in
            
            completionHandler(user: dataArray[0] as? [String: AnyObject], permissions: dataArray[1] as? [String: AnyObject] )
            
        }
    }
    
    func changePermission(subscribtion: [String: AnyObject]!) {
        socket.emit("changePermission", subscribtion)
    }
    
//    func getHeartRates(user: [String: AnyObject], completionHandler: (userHeartRatesData: [[String: AnyObject]]?) -> Void) {
//        
//        socket.emit("getHeartRates", user)
//        
//        socket.on("successHeartRates") { ( dataArray, ack) -> Void in
//            let flag = dataArray[1]
//            if (flag as! NSObject == 0){
//                completionHandler(userHeartRatesData: dataArray[0] as? [[String: AnyObject]])
//            }
//            else{
//                //garbage values
//                completionHandler(userHeartRatesData: [[ "dob": 20, "lastName": 3]])
//            }
//        }
//        
//    }
//    
//    func getUpdates(user: [String: AnyObject], completionHandler: (messageInfo: [[String: AnyObject]]?) -> Void) {
//        socket.on("newHeartBeats") { (dataArray, socketAck) -> Void in
//            
//            let a = dataArray[0]["publisher"] as? String
//            let b = user["_id"] as! String
//            if(a == b){
//                completionHandler(messageInfo: dataArray[0] as? [[String : AnyObject]])
//            }
//            
//        }
//    }
    
    func requestSubscription(userID: String?, publishersUsername: String, completionHandler: (subscription: [String: AnyObject]?) -> Void) {
        socket.emit("requestSubscription", userID!, publishersUsername)
        
        socket.on("successRequesting") { ( dataArray, ack) -> Void in
            
            completionHandler(subscription: dataArray[0] as? [String: AnyObject])
        }
    }
    
    func getSubscribtion(userID: String?, subscriberID: String, completionHandler: (subscribtion: [String: AnyObject]?) -> Void) {
        
        socket.emit("getSubscribtion", userID!, subscriberID)
        
        socket.on("successSubscribtion") { ( dataArray, ack) -> Void in
            
            completionHandler(subscribtion: dataArray[0] as? [String: AnyObject] )
            
        }
    }
    
    func sendMessage(conversationID: String?, loggedUser: String, user2: String, message: String) {
        socket.emit("chatMessage", conversationID!, loggedUser, user2, message)
    }
    
    func getChatMessage(completionHandler: (messageInfo: [String: AnyObject]?) -> Void) {
        socket.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["from"] = dataArray[0] as! String
            messageDictionary["message"] = dataArray[1] as! String
            messageDictionary["date"] = dataArray[2] as! String
//            let json = JSON(dataArray[3])
//            messageDictionary["conversation"] = json[0]["_id"].string
            messageDictionary["conversation"] = dataArray[3] as! String
            
            completionHandler(messageInfo: messageDictionary)
        }
    }
    
    func getMessages(conversationID: String?, completionHandler: (chat: [[String: AnyObject]]?) -> Void) {
        
        socket.emit("getChatMessages", conversationID!)
        
        socket.on("successChatMessages") { ( dataArray, ack) -> Void in
            
            completionHandler(chat: dataArray[0] as? [[String: AnyObject]])
            
        }
    }

    func getConversationID(loggedUser: String?, user2: String, completionHandler: (conversationID: String?) -> Void) {
        
        socket.emit("getConversationID", loggedUser!, user2)
        
        socket.on("successConversationID") { ( dataArray, ack) -> Void in
            
            let json = JSON(dataArray[0])
            
            completionHandler(conversationID: json[0]["_id"].string  )
            
        }
    }
    
    func getConversationsList(userID: String?, completionHandler: (conversationsList: [[String: AnyObject]]?) -> Void) {
        
        socket.emit("getConversationsList", userID!)
        
        socket.on("successConversationsList") { (dataArray, socketAck) -> Void in
            
            completionHandler(conversationsList: dataArray[0] as? [[String : AnyObject]])
        }
    }
    
}
