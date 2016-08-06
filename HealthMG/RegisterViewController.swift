//
//  RegisterViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/1/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import Alamofire
import SimpleKeychain
import ARSLineProgress
import SwiftyJSON
import Eureka
import ChameleonFramework

class RegisterViewController: FormViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Mandatory Fields")
            <<< TextRow("username"){ row in
                row.title = "Username"
                row.placeholder = "Enter Username"
                row.value?.lowercaseString
            }
            <<< PasswordRow("password"){ row in
                row.title = "Password"
                row.placeholder = "Enter Password"
            }
            <<< NameRow("fName"){ row in
                row.title = "First Name"
                row.placeholder = "Enter First Name"
            }
            <<< NameRow("lName"){ row in
                row.title = "Last Name"
                row.placeholder = "Enter Last Name"
            }
            <<< EmailRow("eMail"){ row in
                row.title = "Email"
                row.placeholder = "Enter e-Mail"
            }
            <<< DateInlineRow("dob"){ row in
                row.title = "Date of Birth"
                row.value = NSDate(timeIntervalSinceReferenceDate: 0)
            }
            <<< PickerInlineRow<String>("gender") { row in
                row.title = "Gender"
                row.options = ["Male","Female"]
                row.value = "Male"    // initially selected
            }
            <<< ButtonRow(){
                $0.title = "Register"
                }.cellSetup { cell, row in
                    cell.backgroundColor = .flatGreenColor()
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = .flatWhiteColor()
                } .onCellSelection({ (cell, row) in
                    
                    let username: TextRow? = self.form.rowByTag("username")
                    let password: PasswordRow? = self.form.rowByTag("password")
                    let fName: NameRow? = self.form.rowByTag("fName")
                    let lName: NameRow? = self.form.rowByTag("lName")
                    let eMail: EmailRow? = self.form.rowByTag("eMail")
                    let dob: DateInlineRow? = self.form.rowByTag("dob")
                    let gender: BaseRow? = self.form.rowByTag("gender")
                    
                    
                    if(username!.value != nil || password!.value != nil || fName!.value != nil || lName!.value != nil || eMail!.value != nil){
                        
                        let path = NSBundle.mainBundle().pathForResource("PropertyList", ofType: "plist")
                        let dict = NSDictionary(contentsOfFile: path!)
                        let url = dict!.objectForKey("awsURL") as! String
                        
                        Alamofire.request(.POST, "http://" + url + "/register", parameters: ["username": username!.value!, "password": password!.value!, "firstName": fName!.value!, "lastName": lName!.value!, "email": eMail!.value!, "dob": String(dob!.value!), "gender": gender!.baseValue! as! AnyObject ], encoding: .JSON)
                            .responseJSON { response in
                                
                                let json = JSON(data: response.data!)
                                
                                if json["user"]["_id"] != nil {
                                    //userInfo.append(userData["lastName"] as! String)
                                    
                                    let jwt = json["token"].string
                                    A0SimpleKeychain().setString(jwt!, forKey:"user-jwt")
                                    
                                    if ARSLineProgress.shown { return }
                                    
                                    progressObject = NSProgress(totalUnitCount: 30)
                                    ARSLineProgress.showWithProgressObject(progressObject!, completionBlock: {
                                        
                                        loggedUser = User(id: json["user"]["_id"].string!, username: json["user"]["username"].string!, fName: json["user"]["firstName"].string!, lName: json["user"]["lastName"].string!, eMail: json["user"]["email"].string!, dob: json["user"]["dateOfBirth"].string!, gender: json["user"]["gender"].string!)
                                        
                                        let userDefaults = NSUserDefaults.standardUserDefaults()
                                        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(loggedUser)
                                        userDefaults.setObject(encodedData, forKey: "loggedUser")
                                        userDefaults.synchronize()
                                        
                                        SocketIOManager.sharedInstance.establishConnection()
                                        
                                        self.performSegueWithIdentifier("registerSegue", sender: nil)
                                    })
                                    
                                    self.progressDemoHelper(success: true)
                                    
                                }
                                else{
                                    if ARSLineProgress.shown { return }
                                    
                                    progressObject = NSProgress(totalUnitCount: 30)
                                    ARSLineProgress.showWithProgressObject(progressObject!, completionBlock: {
                                        print("This copmletion block is going to be overriden by cancel completion block in launchTimer() method.")
                                    })
                                    
                                    self.progressDemoHelper(success: false)
                                    
                                    let alertView = UIAlertController(title: "Problem Registering",
                                        message: "Please check the field entered" as String, preferredStyle:.Alert)
                                    let okAction = UIAlertAction(title: "Retry", style: .Default, handler: nil)
                                    alertView.addAction(okAction)
                                    self.presentViewController(alertView, animated: true, completion: nil)
                                }
                        }
                    }

                })

            <<< ButtonRow(){
                $0.title = "Cancel"
                }.cellSetup { cell, row in
                    cell.backgroundColor = .flatRedColor()
                }.cellUpdate { cell, row in
                    cell.textLabel?.textColor = .flatWhiteColor()
                } .onCellSelection({ (cell, row) in
                    self.performSegueWithIdentifier("cancelSegue", sender: nil)
                })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    //To dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

}

private var progress: CGFloat = 0.0
private var progressObject: NSProgress?
private var isSuccess: Bool?

extension RegisterViewController {
    
    private func progressDemoHelper(success success: Bool) {
        isSuccess = success
        launchTimer()
    }
    
    private func launchTimer() {
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.7 * Double(NSEC_PER_SEC)));
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            progressObject!.completedUnitCount += Int64(arc4random_uniform(30))
            
            if isSuccess == false && progressObject?.fractionCompleted >= 0.7 {
                ARSLineProgress.cancelPorgressWithFailAnimation(true, completionBlock: {
                    print("Hidden with completion block")
                })
                return
            } else {
                if progressObject?.fractionCompleted >= 1.0 { return }
            }
            
            self.launchTimer()
        })
    }
    
}

