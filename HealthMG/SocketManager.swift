//
//  SocketManager.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/5/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import SocketIOClientSwift
import SimpleKeychain

var connected : Bool = false

class SocketIOManager: NSObject {
    
    //Singleton
    static let sharedInstance = SocketIOManager()
    
    
    
//    let keychain = Keychain(server: "https://testing.herokuapp.com", protocolType: .HTTPS)
//    
//    var token: String {
//        get {
//            if let realToken = keychain["token"] {
//                return String(realToken)
//            } else {
//                return ""
//            }
//            
//        }
//    }
    //retrieve saved token
    let jwt = A0SimpleKeychain().stringForKey("user-jwt")
    
    lazy var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://10.0.0.13:3007")!,
                                                options: [.Log(true), .ConnectParams(["token": self.jwt])])
    
    override init() {
        super.init()
    }
    
    func establishConnection() {
        if connected == false{
            socket.connect()
            
            socket.on("connect") {data, ack in
                connected = true
                print("socket connected")
            }
        }
    }
    
    func closeConnection() {
        if connected == true{
            socket.disconnect()
            connected = false
        }
    }
    
    func login(username: String, password: String, completionHandler: (userData: [String: AnyObject?]!) -> Void) {
        
        socket.emit("login", username, password)
        
        socket.on("successLogin") { ( dataArray, ack) -> Void in
            print("Login Success!")
            completionHandler(userData: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("error") { (dataArray, socketAck) -> Void in
            print("Login Failure!")
            let noUser : [String : AnyObject?] = ["_id" : nil]
            completionHandler(userData: noUser)
        }
    }
    
    func register(username: String, password: String, firstName: String, lastName: String, email:String, dob:String, gender:String, completionHandler: (userData: [String: AnyObject]!) -> Void) {
        
        socket.emit("register", username, password, firstName, lastName)
        
        socket.on("successRegistering") { ( dataArray, ack) -> Void in
            
            completionHandler(userData: dataArray[0] as! [String: AnyObject])
        }
        
        socket.on("error") { (dataArray, socketAck) -> Void in
        }
    }
    
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
    
    
    func getLatestRecords(user: [String: AnyObject], completionHandler: (latestRecords: [[String: AnyObject]]!) -> Void) {
        
        socket.emit("getLatestRecords", user)
        
        socket.on("successLatestRecords") { ( dataArray, ack) -> Void in
            let flag = dataArray[1]
            if (flag as! NSObject == 0){
                completionHandler(latestRecords: dataArray[0] as! [[String: AnyObject]])
            }
            else{
                //garbage values
                completionHandler(latestRecords: [[ "dob": 20, "lastName": 3]])
            }
        }
        
        socket.on("error") { (dataArray, socketAck) -> Void in
        }
    }
    
    
    func getPublishersList(user: [String: AnyObject], completionHandler: (subscriptionData: [[String: AnyObject]]!) -> Void) {
        
        socket.emit("getPublishersList", user)
        
        socket.on("successPubList") { ( dataArray, ack) -> Void in
            
            completionHandler(subscriptionData: dataArray[0] as! [[String: AnyObject]] )
            
        }
    }
    
    func getHeartRates(user: [String: AnyObject], completionHandler: (userHeartRatesData: [[String: AnyObject]]!) -> Void) {
        
        socket.emit("getHeartRates", user)
        
        socket.on("successHeartRates") { ( dataArray, ack) -> Void in
            let flag = dataArray[1]
            if (flag as! NSObject == 0){
                completionHandler(userHeartRatesData: dataArray[0] as! [[String: AnyObject]])
            }
            else{
                //garbage values
                completionHandler(userHeartRatesData: [[ "dob": 20, "lastName": 3]])
            }
        }
        
    }
    
    func getUpdates(user: [String: AnyObject], completionHandler: (messageInfo: [[String: AnyObject]]) -> Void) {
        socket.on("newHeartBeats") { (dataArray, socketAck) -> Void in
            
            let a = dataArray[0]["publisher"] as! String
            let b = user["_id"] as! String
            if(a == b){
                completionHandler(messageInfo: dataArray[0] as! [[String : AnyObject]])
            }
            
        }
    }
    
    
    func addSubscription(userID: String, publishersUsername: String, completionHandler: (subscription: [String: AnyObject]!) -> Void) {
        socket.emit("addSubscription", userID, publishersUsername)
        
        socket.on("successSubscribing") { ( dataArray, ack) -> Void in
            
            print(dataArray[0])
            
            completionHandler(subscription: dataArray[0] as! [String: AnyObject])
        }
    }
    
    
    
    
}
