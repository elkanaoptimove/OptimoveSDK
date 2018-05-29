//
//  Ping.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 13/05/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

class PingEvent: OptimoveEvent,OptimovePredefinedEvent{
    var name: String
    {
        return "notification_ping"
    }
    
    var parameters: [String : Any]
    {
        var dictionary = [Keys.Configuration.appNs.rawValue: Bundle.main.bundleIdentifier!,
                          Keys.Configuration.deviceId.rawValue: DeviceID]
        if CustomerID == nil {
            dictionary[Keys.Configuration.visitorId.rawValue] = VisitorID ?? ""
        } else {
            dictionary[Keys.Configuration.userId.rawValue] = CustomerID!
        }
        return dictionary
    }
}
