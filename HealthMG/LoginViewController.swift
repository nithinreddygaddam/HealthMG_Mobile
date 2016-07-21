//
//  LoginViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 6/30/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import ChameleonFramework
import ARSLineProgress
import Alamofire
import SwiftyJSON
import SimpleKeychain
import SkyFloatingLabelTextField

var loggedUser = User();

class LoginViewController: UIViewController {
    
    let username = SkyFloatingLabelTextField(frame: CGRectMake(90, 200, 200, 45))
    let password = SkyFloatingLabelTextField(frame: CGRectMake(90, 250, 200, 45))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.placeholder = "Username"
        username.title = "Username"
        username.autocapitalizationType = .None
        self.view.addSubview(username)
        
        username.tintColor = UIColor.flatSkyBlueColorDark() // the color of the blinking cursor
        username.textColor = UIColor.flatWhiteColor()
        username.placeholderColor = UIColor.flatWhiteColor()
        username.lineColor = UIColor.flatWhiteColor()
        username.selectedTitleColor = UIColor.flatSkyBlueColor()
        username.selectedLineColor = UIColor.flatSkyBlueColor()
    
        password.placeholder = "Password"
        password.title = "Password"
        password.secureTextEntry = true
        self.view.addSubview(password)
        
        password.tintColor = UIColor.flatSkyBlueColorDark() // the color of the blinking cursor
        password.textColor = UIColor.flatWhiteColor()
        password.placeholderColor = UIColor.flatWhiteColor()
        password.lineColor = UIColor.flatWhiteColor()
        password.selectedTitleColor = UIColor.flatSkyBlueColor()
        password.selectedLineColor = UIColor.flatSkyBlueColor()
    
    }
    
    //To dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func IBLogin(sender: AnyObject) {
        
        view.endEditing(true) //dismiss keyboard
        
        if(self.username.text != nil && self.password.text != nil){
            
            Alamofire.request(.POST, "http://127.0.0.1:3000/login", parameters: ["username": self.username.text!, "password": self.password.text!]) //check the comma!!!!
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
                        print(jwt)
                    
                    loggedUser = User(id: json["user"]["_id"].string!, username: json["user"]["username"].string!, fName: json["user"]["firstName"].string!, lName: json["user"]["lastName"].string!, eMail: json["user"]["email"].string!, dob: json["user"]["dateOfBirth"].string!, gender: json["user"]["gender"].string!)
                        
                    SocketIOManager.sharedInstance.establishConnection()
                        self.performSegueWithIdentifier("loginSegue", sender: nil)

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
                    }
                }
            }
        }
    }


private var progress: CGFloat = 0.0
private var progressObject: NSProgress?
private var isSuccess: Bool?

extension LoginViewController {
    
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
