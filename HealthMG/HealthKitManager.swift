//
//  HealthKitManager.swift
//  HealthMG
//
//  Created by Nithin Reddy Gaddam on 7/27/16.
//  Copyright © 2016 Nithin Reddy Gaddam. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager {
    class var sharedInstance: HealthKitManager {
        struct Singleton {
            static let instance = HealthKitManager()
        }
        return Singleton.instance
    }
    
    let healthStore: HKHealthStore? = {
        if HKHealthStore.isHealthDataAvailable() {
            return HKHealthStore()
        } else {
            return nil
        }
    }()
    
    let quantityType:[AnyObject] = [HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)!, HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning)!, HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned)!, HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)!]
    let units:[AnyObject] = [HKUnit.countUnit(), HKUnit.mileUnit(), HKUnit.kilocalorieUnit(), HKUnit.minuteUnit()  ]

}