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

class RegisterViewController: FormViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ Section("Mandatory Fields")
            <<< TextRow("username"){ row in
                row.title = "Username"
                row.placeholder = "Enter Username"
            }
            <<< PasswordRow("password"){
                $0.title = "Password"
                $0.placeholder = "Enter Password"
            }
            <<< NameRow("fName"){
                $0.title = "First Name"
                $0.placeholder = "Enter First Name"
            }
            <<< NameRow("lName"){
                $0.title = "Last Name"
                $0.placeholder = "Enter Last Name"
            }
            <<< EmailRow("eMail"){
                $0.title = "Email"
                $0.placeholder = "Enter e-Mail"
            }
            <<< DateInlineRow("dob"){
                $0.title = "Date of Birth"
                $0.value = NSDate(timeIntervalSinceReferenceDate: 0)
            }
            <<< PickerInlineRow<String>("gender") {
                $0.title = "Gender"
                $0.options = ["Male","Female"]
                $0.value = "Male"    // initially selected
            }
            +++ Section("Register")
            <<< ButtonRow(){
                $0.title = "Register"
                } .onCellSelection({ (cell, row) in
                    
                    let username: TextRow? = self.form.rowByTag("username")
                    let password: PasswordRow? = self.form.rowByTag("password")
                    let fName: NameRow? = self.form.rowByTag("fName")
                    let lName: NameRow? = self.form.rowByTag("lName")
                    let eMail: EmailRow? = self.form.rowByTag("eMail")
                    let dob: DateInlineRow? = self.form.rowByTag("dob")
                    let gender: BaseRow? = self.form.rowByTag("gender")
                    
                    
                    if(username!.value != nil && password!.value != nil && fName!.value != nil && lName!.value != nil){
                        Alamofire.request(.POST, "http://127.0.0.1:3000/register", parameters: ["username": username!.value!, "password": password!.value!, "firstName": fName!.value!, "lastName": lName!.value!, "email": eMail!.value!, "dob": dob!.value!, "gender": gender!.baseValue! as! AnyObject ])
                            .responseJSON { response in
                                
                                let json = JSON(data: response.data!)
                                
                                if json["user"]["_id"] != nil {
                                    //userInfo.append(userData["lastName"] as! String)
                                    
                                    let jwt = json["token"].string
                                    A0SimpleKeychain().setString(jwt!, forKey:"user-jwt")
                                    
                                    if ARSLineProgress.shown { return }
                                    
                                    progressObject = NSProgress(totalUnitCount: 60)
                                    ARSLineProgress.showWithProgressObject(progressObject!, completionBlock: {
                                        
                                        print(json["user"])
                                        
                                        loggedUser = User(id: json["user"]["_id"].string!, username: json["user"]["username"].string!, fName: json["user"]["firstName"].string!, lName: json["user"]["lastName"].string!, eMail: json["user"]["email"].string!, dob: json["user"]["dateOfBirth"].string!, gender: json["user"]["gender"].string!)
                                        
                                        //saving user details to user defaults
                                        let userDefaults = NSUserDefaults.standardUserDefaults()
                                        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(loggedUser)
                                        userDefaults.setObject(encodedData, forKey: "loggedUser")
                                        
                                        SocketIOManager.sharedInstance.establishConnection()
                                        
                                        self.performSegueWithIdentifier("registerSegue", sender: nil)
                                    })
                                    
                                    self.progressDemoHelper(success: true)
                                    
                                }
                                else{
                                    if ARSLineProgress.shown { return }
                                    
                                    progressObject = NSProgress(totalUnitCount: 60)
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
            +++ Section("Cancel")
            <<< ButtonRow(){
                $0.title = "Cancel"
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

