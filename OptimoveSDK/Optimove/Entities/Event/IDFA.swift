//
//  IDFA.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 13/05/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation
import AdSupport

class SetAdvertisingId : OptimoveEvent,OptimovePredefinedEvent
{
    var name: String
    {
        return Keys.Configuration.setAdvertisingId.rawValue
    }
    
    var parameters: [String : Any]
    {
        return [Keys.Configuration.advertisingId.rawValue   : ASIdentifierManager.shared().advertisingIdentifier.uuidString ,
                Keys.Configuration.deviceId.rawValue        : DeviceID,
                Keys.Configuration.appNs.rawValue           : Bundle.main.bundleIdentifier!]
    }
}
