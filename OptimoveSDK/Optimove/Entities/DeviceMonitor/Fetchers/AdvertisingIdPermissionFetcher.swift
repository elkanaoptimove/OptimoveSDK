//
//  AdvertisingIdPermissionFetcher.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 22/02/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation
import AdSupport
class AdvertisingIdPermissionFetcher: Fetchable {
    func fetch(completionHandler: @escaping ResultBlockWithBool) {
        completionHandler(ASIdentifierManager.shared().isAdvertisingTrackingEnabled)
    }
}
