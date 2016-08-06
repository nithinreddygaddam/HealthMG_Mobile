//
//  PermissionViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/16/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import Eureka

class PermissionViewController: FormViewController {
    
    var user2: [String: AnyObject] = [ : ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("Profile")
            <<< TextRow("username"){ row in
                row.title = "Username"
                row.placeholder = user2["username"] as? String
            }
            <<< NameRow("fName"){
                $0.title = "First Name"
                $0.placeholder = user2["firstName"] as? String
            }
            <<< NameRow("lName"){
                $0.title = "Last Name"
                $0.placeholder = user2["lastName"] as? String
            }
            <<< EmailRow("eMail"){
                $0.title = "Email"
                $0.placeholder = user2["email"] as? String
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
            <<< SwitchRow("heartRate") { row in
                row.title = "Heart Rate"
                row.value = subscribtion["heartRate"] as? Bool
                }.onChange { row in
                    subscribtion["heartRate"] = row.value
                    
            }
            <<< SwitchRow("distance") { row in
                row.title = "Distance"
                row.value = subscribtion["distance"] as? Bool
                }.onChange { row in
                    subscribtion["distance"] = row.value
                    
            }
            <<< SwitchRow("stepCount") { row in
                row.title = "Step Count"
                row.value = subscribtion["stepCount"] as? Bool
                }.onChange { row in
                    subscribtion["stepCount"] = row.value
                    
            }
            <<< SwitchRow("calories") { row in
                row.title = "Calories"
                row.value = subscribtion["calories"] as? Bool
                }.onChange { row in
                    subscribtion["calories"] = row.value
            }
            <<< ButtonRow(){
                $0.title = "Save Permissions"
                } .onCellSelection({ (cell, row) in
                        SocketIOManager.sharedInstance.changePermission(subscribtion)
                    self.navigationController!.popToRootViewControllerAnimated(true)
                })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

