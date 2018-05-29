//
//  OptimoveComponent.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 27/02/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

class OptimoveComponent
{
    var isEnable = false
    
    var deviceStateMonitor:OptimoveDeviceStateMonitor
    
    init(deviceStateMonitor: OptimoveDeviceStateMonitor)
    {
        self.deviceStateMonitor = deviceStateMonitor
    }
    func performInitializationOperations(){}
//    
//    func configure(from json:[String:Any?], didComplete:ResultBlockWithBool) {
//        getComponentInitializer(json,didComplete).execute()
//    }
//    
//    func getComponentInitializer(from json:[String:Any?], didComplete:ResultBlockWithBool) -> OptimoveComponent {
//        
//    }
}
