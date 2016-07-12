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

var loggedUser = User();

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.view.backgroundColor = UIColor.flatGreenColor()

        // Do any additional setup after loading the view.
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
    
    
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBAction func IBLogin(sender: AnyObject) {
        //Keychain framework for credentials
        
        view.endEditing(true) //dismiss keyboard
        
        if(self.txtUsername.text != nil && self.txtPassword.text != nil){
            SocketIOManager.sharedInstance.login(self.txtUsername.text!, password: self.txtPassword.text!, completionHandler: { (userData) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if userData["_id"]! != nil {
//                        userInfo.append(userData["lastName"] as! String)
                        if ARSLineProgress.shown { return }
                        
                        progressObject = NSProgress(totalUnitCount: 60)
                        ARSLineProgress.showWithProgressObject(progressObject!, completionBlock: {
                            
                            print(userData)
                            
                            loggedUser = User(id: userData["_id"] as! String, username: userData["username"] as! String, fName: userData["firstName"] as! String, lName: userData["lastName"] as! String, eMail: userData["email"] as! String, dob: userData["dateOfBirth"] as! String, gender: userData["gender"] as! String)
                            
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
                    
                })
            })
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
