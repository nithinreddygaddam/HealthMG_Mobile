//
//  Request.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/8/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import UIKit

class Request: NSObject {
    var id      : String!
    var username : String!
    var fName   : String!
    var lName   : String!
    var eMail   : String!
    var dob     : String!
    var gender  : String!
    
    init(   id      : String,
            username : String,
            fName   : String,
            lName   : String,
            eMail   : String,
            dob     : String,
            gender  : String){
        
        super.init()
        self.id         = id
        self.username   = username
        self.fName      = fName
        self.lName      = lName
        self.eMail      = eMail
        self.dob        = dob
        self.gender     = gender
    }
    
    override init(){
        
    }

}
