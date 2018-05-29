//
//  Opt.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 13/05/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation
class Opt :OptimoveEvent,OptimovePredefinedEvent
{
    var name: String
    {
        return ""
    }
    var parameters: [String : Any]
    {
        return [Keys.Configuration.timestamp.rawValue   : Int(Date().timeIntervalSince1970),
                Keys.Configuration.appNs.rawValue       : Bundle.main.bundleIdentifier!,
                Keys.Configuration.deviceId.rawValue    : DeviceID]
    }
}

class OptipushOptIn: Opt
{
    override var name: String
    {
        return Keys.Configuration.optipushOptIn.rawValue
    }
}

class OptipushOptOut: Opt
{
    override var name: String
    {
        return Keys.Configuration.optipushOptOut.rawValue
    }
}
