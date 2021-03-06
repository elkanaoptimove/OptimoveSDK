//
//  UserPushToken.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 25/04/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

struct MbaasRequestBody:Codable,CustomStringConvertible
{
    let tenantId: Int
    let deviceId:String
    let appNs:String
    let osVersion:String
    
    var visitorId : String?
    var publicCustomerId: String?
    
    var optIn:Bool?
    
    var token: String?
    let operation:MbaasOperations
    var isConversion: Bool?
    
    var description: String {
       return  "tenantId=\(tenantId)&deviceId=\(deviceId)&appNs=\(appNs)&osVersion=\(osVersion)&visitorId=\(visitorId ?? "" )&publicCustomerId=\(publicCustomerId ?? "")&optIn=\(optIn?.description ?? "")&token=\(token ?? "")&operation=\(operation)&isConversion=\(isConversion?.description ?? "")"
        
    }

    init(operation: MbaasOperations)
    {
        self.operation = operation
        tenantId = TenantID ?? -1
        deviceId = DeviceID
        appNs = Bundle.main.bundleIdentifier?.replacingOccurrences(of: ".", with: "_") ?? ""
        osVersion = OSVersion
    }
    func toMbaasJsonBody() ->Data?
    {
        var requestJsonData = [String: Any]()
        switch operation {
        case .optIn: fallthrough
        case .optOut: fallthrough
        case .unregistration:
            let iOSToken = [Keys.Registration.bundleID.rawValue : appNs,
                            Keys.Registration.deviceID.rawValue : DeviceID ]
            requestJsonData[Keys.Registration.iOSToken.rawValue]    = iOSToken
            requestJsonData[Keys.Registration.tenantID.rawValue]    = TenantID
            if let customerId = UserInSession.shared.customerID {
                requestJsonData[Keys.Registration.customerID.rawValue] = customerId
            } else {
                requestJsonData[Keys.Registration.visitorID.rawValue]   = VisitorID
            }
        case .registration:
            var bundle = [String:Any]()
            bundle[Keys.Registration.optIn.rawValue] = UserInSession.shared.isMbaasOptIn 
            bundle[Keys.Registration.token.rawValue] = UserInSession.shared.fcmToken
            let app = [appNs: bundle]
            var device: [String: Any] = [Keys.Registration.apps.rawValue: app]
            device[Keys.Registration.osVersion.rawValue] = OSVersion
            let ios = [deviceId: device]
            requestJsonData[Keys.Registration.iOSToken.rawValue]         = ios
            requestJsonData[Keys.Registration.tenantID.rawValue]         = UserInSession.shared.siteID
            
            if let customerId = UserInSession.shared.customerID {
                requestJsonData[Keys.Registration.origVisitorID.rawValue]    = UserInSession.shared.visitorID
                
                if UserInSession.shared.isFirstConversion == nil {
                    UserInSession.shared.isFirstConversion = true
                } else {
                    UserInSession.shared.isFirstConversion = false
                }
                
                requestJsonData[Keys.Registration.isConversion.rawValue]    = UserInSession.shared.isFirstConversion
                requestJsonData[Keys.Registration.customerID.rawValue]       = customerId
            } else {
                requestJsonData[Keys.Registration.visitorID.rawValue]        = UserInSession.shared.visitorID
            }
            
        }
        let dictionary = [operation.rawValue : requestJsonData]
        return try! JSONSerialization.data(withJSONObject: dictionary, options: [])
    }
}
