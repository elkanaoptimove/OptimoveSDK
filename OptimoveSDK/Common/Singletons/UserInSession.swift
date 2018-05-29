//
//  UserInSession.swift
//  OptimoveSDKDev
//
//  Created by Mobile Developer Optimove on 11/09/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import Foundation

class UserInSession: Synchronizable
{
    let lock:NSLock
    enum UserDefaultsKeys: String
    {
        case configurationEndPoint          = "configurationEndPoint"
        case isMbaasOptIn                   = "isMbaasOptIn"
        case isOptiTrackOptIn               = "isOptiTrackOptIn"
        case isFirstConversion              = "isFirstConversion"
        case tenantToken                    = "tenantToken"
        case siteID                         = "siteID"
        case version                        = "version"
        case customerID                     = "customerID"
        case visitorID                      = "visitorID"
        case deviceToken                    = "deviceToken"
        case fcmToken                       = "fcmToken"
        case defaultFcmToken                = "defaultFcmToken"
        case isFirstLaunch                  = "isFirstLaunch"
        case userAgentHeader                = "userAgentHeader"
        case unregistrationSuccess          = "unregistrationSuccess"
        case registrationSuccess            = "registrationSuccess"
        case optSuccess                     = "optSuccess"
        case isSetUserIdSucceed             = "isSetUserIdSucceed"
        case isClientHasFirebase            = "userHasFirebase"
        case isClientUseFirebaseMessaging   = "isClientUseFirebaseMessaging"
        case apnsToken                      = "apnsToken"
        case hasConfigurationFile           = "hasConfigurationFile"
        case topics                         = "topic"
        case openAppTime                    = "openAppTime"
        case clientUseBackgroundExecution   = "clientUseBackgroundExecution"
        case lastPingTime                   = "lastPingTime"
        case realtimeSetUserIdFailed        = "realtimeSetUserIdFailed"
    }
    
    static let shared = UserInSession()
    private init()
    {
        lock = NSLock()
    }
    
    //MARK: Persist data
    var customerID:String?
    {
        get
        {
            if let id = UserDefaults.standard.string(forKey: UserDefaultsKeys.customerID.rawValue)
            {
                return id
            }
            return nil
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any, key: UserDefaultsKeys.customerID.rawValue)
        }
    }
    var visitorID:String?
    {
        get
        {
            if let id = UserDefaults.standard.string(forKey: UserDefaultsKeys.visitorID.rawValue)
            {
                return id
            }
            return nil
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any, key: UserDefaultsKeys.visitorID.rawValue)
        }
    }
    var apnsToken: Data?
    {
        get
        {
            return UserDefaults.standard.data(forKey: UserDefaultsKeys.apnsToken.rawValue)
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any, key: UserDefaultsKeys.apnsToken.rawValue)
        }
    }
    
    //MARK: Initializtion Flags
    var configurationEndPoint: String
    {
        get
        {
            if let id = UserDefaults.standard.string(forKey: UserDefaultsKeys.configurationEndPoint.rawValue)
            {
                return id
            }
            return ""
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any,
                                  key: UserDefaultsKeys.configurationEndPoint.rawValue)
        }
    }
    var siteID:Int?
    {
        get
        {
            if let id = UserDefaults.standard.value(forKey: UserDefaultsKeys.siteID.rawValue) as? Int
            {
                return id
            }
            return nil
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any, key: UserDefaultsKeys.siteID.rawValue)
        }
    }
    var tenantToken: String?
    {
        get
        {
            if let id = UserDefaults.standard.string(forKey: UserDefaultsKeys.tenantToken.rawValue)
            {
                return id
            }
            return nil
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any, key: UserDefaultsKeys.tenantToken.rawValue)
        }
    }
    var version:String?
    {
        get
        {
            if let id = UserDefaults.standard.string(forKey: UserDefaultsKeys.version.rawValue) {
                return id
            }
            return nil
        }
        set { self.setDefaultObject(forObject: newValue as Any,
                                    key: UserDefaultsKeys.version.rawValue) }
    }
    var hasConfigurationFile : Bool?
    {
        get
        {
            return UserDefaults.standard.value(forKey: UserDefaultsKeys.hasConfigurationFile.rawValue) as? Bool
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any,
                                  key: UserDefaultsKeys.hasConfigurationFile.rawValue)
        }
    }
    var isClientHasFirebase : Bool
    {
        get { return UserDefaults.standard.bool(forKey: UserDefaultsKeys.isClientHasFirebase.rawValue)}
        set { self.setDefaultObject(forObject: newValue as Any,
                                    key: UserDefaultsKeys.isClientHasFirebase.rawValue) }
    }
    var isClientUseFirebaseMessaging : Bool
    {
        get { return UserDefaults.standard.bool(forKey: UserDefaultsKeys.isClientUseFirebaseMessaging.rawValue)}
        set { self.setDefaultObject(forObject: newValue as Any,
                                    key: UserDefaultsKeys.isClientUseFirebaseMessaging.rawValue) }
    }
    
   
    // MARK: Optipush Flags
    var isMbaasOptIn: Bool?
    {
        get
        {
            lock.lock()
            let val = UserDefaults.standard.value(forKey: UserDefaultsKeys.isMbaasOptIn.rawValue) as? Bool
            lock.unlock()
            return val
        }
        set
        {
            lock.lock()
            self.setDefaultObject(forObject: newValue as Any,
                                  key: UserDefaultsKeys.isMbaasOptIn.rawValue)
            lock.unlock()
        }
    }
    var isUnregistrationSuccess : Bool
    {
        get
        {
            return (UserDefaults.standard.value(forKey: UserDefaultsKeys.unregistrationSuccess.rawValue) as? Bool) ?? true
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any,
                                  key: UserDefaultsKeys.unregistrationSuccess.rawValue)
        }
    }
    var isRegistrationSuccess : Bool
    {
        get
        {
            return (UserDefaults.standard.value(forKey: UserDefaultsKeys.registrationSuccess.rawValue) as? Bool) ?? true
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any,
                                  key: UserDefaultsKeys.registrationSuccess.rawValue)
        }
    }
    var isOptRequestSuccess : Bool
    {
        get
        {
            return (UserDefaults.standard.value(forKey: UserDefaultsKeys.optSuccess.rawValue) as? Bool) ?? true
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any,
                                  key: UserDefaultsKeys.optSuccess.rawValue)
        }
    }
    var isFirstConversion : Bool?
    {
        get { return UserDefaults.standard.value(forKey: UserDefaultsKeys.isFirstConversion.rawValue) as? Bool }
        set { self.setDefaultObject(forObject: newValue as Any,
                                    key: UserDefaultsKeys.isFirstConversion.rawValue) }
    }
    var defaultFcmToken: String?
    {
        get
        {
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.defaultFcmToken.rawValue) ?? nil
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any, key: UserDefaultsKeys.defaultFcmToken.rawValue)
        }
    }
    var fcmToken: String?
    {
        get
        {
            return UserDefaults.standard.string(forKey: UserDefaultsKeys.fcmToken.rawValue) ?? nil
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any, key: UserDefaultsKeys.fcmToken.rawValue)
        }
    }
    // MARK: OptiTrack Flags
    var isOptiTrackOptIn: Bool?
    {
        get
        {
            lock.lock()
            let val = UserDefaults.standard.value(forKey: UserDefaultsKeys.isOptiTrackOptIn.rawValue) as? Bool
            lock.unlock()
            return val
        }
        set
        {
            lock.lock()
            self.setDefaultObject(forObject: newValue as Any,
                                  key: UserDefaultsKeys.isOptiTrackOptIn.rawValue)
            lock.unlock()
        }
    }
    var lastPingTime: TimeInterval
    {
        get { return UserDefaults.standard.double(forKey: UserDefaultsKeys.lastPingTime.rawValue)}
        set { self.setDefaultObject(forObject: newValue as Any,
                                    key: UserDefaultsKeys.lastPingTime.rawValue) }
    }
    var isSetUserIdSucceed : Bool
    {
        get { return  UserDefaults.standard.bool(forKey: UserDefaultsKeys.isSetUserIdSucceed.rawValue)}
        
        set { self.setDefaultObject(forObject: newValue as Bool,
                                    key: UserDefaultsKeys.isSetUserIdSucceed.rawValue) }
    }
    // MARK: Real time flags
    var realtimeSetUserIdFailed: Bool
    {
        get
        {
            return UserDefaults.standard.bool(forKey: UserDefaultsKeys.realtimeSetUserIdFailed.rawValue)
        }
        set
        {
            self.setDefaultObject(forObject: newValue as Any,
                                  key: UserDefaultsKeys.realtimeSetUserIdFailed.rawValue)
        }
    }
}
