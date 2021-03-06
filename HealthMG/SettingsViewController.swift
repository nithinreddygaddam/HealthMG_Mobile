//
//  SettingsViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/8/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import Eureka
import SimpleKeychain

class SettingsViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Mandatory Fields")
            <<< TextRow("username"){ row in
                row.title = "Username"
                row.placeholder = loggedUser.username
            }
//            <<< PasswordRow("password"){
//                $0.title = "Password"
//                $0.placeholder =
//            }
            <<< NameRow("fName"){
                $0.title = "First Name"
                $0.placeholder = loggedUser.fName
            }
            <<< NameRow("lName"){
                $0.title = "Last Name"
                $0.placeholder = loggedUser.lName
            }
            <<< EmailRow("eMail"){
                $0.title = "Email"
                $0.placeholder = loggedUser.eMail
            }
            <<< DateInlineRow("dob"){
                $0.title = "Date of Birth"
                $0.value = NSDate(timeIntervalSinceReferenceDate: 0)
            }
            <<< PickerInlineRow<String>("gender") {
                $0.title = "Gender"
                $0.options = ["Male","Female"]
                $0.value = loggedUser.gender
            }
        +++ Section("Log Out")
            <<< ButtonRow(){
                $0.title = "Log Out"
                } .onCellSelection({ (cell, row) in
                    SocketIOManager.sharedInstance.closeConnection()
                    A0SimpleKeychain().deleteEntryForKey("user-jwt")
                    
                    loggedUser = User()
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    let encodedData = NSKeyedArchiver.archivedDataWithRootObject(loggedUser)
                    userDefaults.setObject(encodedData, forKey: "loggedUser")
                    userDefaults.synchronize()
                    
                    self.performSegueWithIdentifier("logOutSegue", sender: nil)
                })
        
            +++ Section("Privacy Policy")
            <<< ButtonRow(){
                $0.title = "Privacy Policy"
                } .onCellSelection({ (cell, row) in
                    let url = NSURL(string: "http://healthmg.weebly.com/privacy-policy.html")!
                    UIApplication.sharedApplication().openURL(url)
                })

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

