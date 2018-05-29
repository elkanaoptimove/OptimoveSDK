//
//  NotificationPermissionFetcher.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 22/02/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationPermissionFetcher:Fetchable {
    func fetch(completionHandler: @escaping ResultBlockWithBool) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized || settings.authorizationStatus == .notDetermined {
                completionHandler(true)
            }
            else {
                completionHandler(false)
            }
        }
    }
}
