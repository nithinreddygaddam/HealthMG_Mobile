//
//  RegisterViewController.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/1/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtDob: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtLName: UITextField!
    @IBOutlet weak var txtFName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtUsername: UITextField!
    
    @IBAction func IBRegister(sender: AnyObject) {
        
        view.endEditing(true) //dismiss keyboard
        
        if(self.txtUsername.text != nil && self.txtPassword.text != nil && self.txtFName.text != nil && self.txtLName.text != nil){
            SocketIOManager.sharedInstance.register(self.txtUsername.text!, password: self.txtPassword.text!, firstName: self.txtFName.text!, lastName: self.txtLName.text!, email: self.txtEmail.text!, dob: self.txtDob.text!, gender: self.txtGender.text!, completionHandler: { (userData) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if userData != nil {
                        print(userData)
//                        userInfo.append(self.lastName.text!)
                        
                        
                        self.performSegueWithIdentifier("registerSegue", sender: nil)
                    }
                    else{
                        let alertView = UIAlertController(title: "Problem Registering",
                            message: "Please check the field entered" as String, preferredStyle:.Alert)
                        let okAction = UIAlertAction(title: "Retry", style: .Default, handler: nil)
                        alertView.addAction(okAction)
                        self.presentViewController(alertView, animated: true, completion: nil)
                    }
                    
                })
            })
        }

    }
    
    @IBAction func IBDOB(sender: AnyObject) {
        
        
        txtDob.resignFirstResponder()
        
        let datePicker = ActionSheetDatePicker(title: "Date:", datePickerMode: UIDatePickerMode.Date, selectedDate: NSDate(), doneBlock: {
            picker, value, index in
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            
            let val:String = String(value)
            let date = dateFormatter.dateFromString(val)
            
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let date2 = dateFormatter.stringFromDate(date!)
            
            self.txtDob.text = date2
            
            return
            }, cancelBlock: { ActionStringCancelBlock in return }, origin: sender.superview!!.superview)
        let secondsInWeek: NSTimeInterval = 52000 * 24 * 60 * 60;
        datePicker.minimumDate = NSDate(timeInterval: -secondsInWeek, sinceDate: NSDate())
        datePicker.maximumDate = NSDate()
        
        datePicker.showActionSheetPicker()
        
        
    }

    
    @IBAction func IBGender(sender: AnyObject) {
        
        view.endEditing(true) //dismiss keyboard
        
        ActionSheetStringPicker.showPickerWithTitle("Gender", rows:
            ["Male", "Female"]
            , initialSelection: 1, doneBlock: {
                picker, value, index in
                
                print("values = \(value)")
                
                self.txtGender.text =  String(index)
                print("index = \(index)")
                print("picker = \(picker)")

                return
            }, cancelBlock: { ActionMultipleStringCancelBlock in return }, origin: sender)
    }
}
