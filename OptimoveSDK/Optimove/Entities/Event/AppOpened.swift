//
//  AppOpened.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 13/05/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation
class AppOpened: OptimoveEvent,OptimovePredefinedEvent
{
    var name: String
    {
        return "app_open"
    }
    
    var parameters: [String : Any]
    {
        var dictionary = [Keys.Configuration.appNs.rawValue: Bundle.main.bundleIdentifier!,
                          Keys.Configuration.deviceId.rawValue: DeviceID,
                          Keys.Configuration.platform.rawValue: Keys.Configuration.ios.rawValue]
        if CustomerID == nil {
            dictionary[Keys.Configuration.visitorId.rawValue] = VisitorID ?? ""
        } else {
            dictionary[Keys.Configuration.userId.rawValue] = CustomerID!
        }
        return dictionary
    }
}
