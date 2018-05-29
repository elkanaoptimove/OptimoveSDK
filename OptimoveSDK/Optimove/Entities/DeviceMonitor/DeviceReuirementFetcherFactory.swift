//
//  DeviceReuirementFetcherFactory.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 22/02/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

class DeviceReuirementFetcherFactory
{
    static var dictionary: [OptimoveDeviceRequirement:Fetchable] = [
        OptimoveDeviceRequirement.advertisingId : AdvertisingIdPermissionFetcher(),
        .userNotification : NotificationPermissionFetcher(),
        OptimoveDeviceRequirement.internet : NetworkCapabilitiesFetcher()]
    
    static func getInstance(requirement: OptimoveDeviceRequirement) -> Fetchable! {
            return dictionary[requirement]
    }
}
