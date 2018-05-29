//
//  Constants.swift
//  iOS-SDK
//
//  Created by Mobile Developer Optimove on 04/09/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import UIKit

struct Keys
{
    enum Registration: String
    {
        case tenantID               = "tenant_id"
        case customerID             = "public_customer_id"
        case visitorID              = "visitor_id"
        case iOSToken               = "ios_token"
        case isVisitor              = "is_visitor"
        case isConversion           = "is_conversion"
        case origVisitorID          = "orig_visitor_id"
        case deviceID               = "device_id"
        case optIn                  = "opt_in"
        case optOut                 = "opt_out"
        case token                  = "token"
        case osVersion              = "os_version"
        case registrationData       = "registration_data"
        case unregistrationData     = "unregistration_data"
        case apps                   = "apps"
        case bundleID               = "app_ns"
        case successStatus          = "success_status"
        case optOutStatus           = "opt-out_status"
    }
    
    enum Configuration: String
    {
        //MARK: General configuration
        case enableOptitrack                            = "enableOptitrack"
        case enableOptipush                             = "enableOptipush"
        case enableVisitors                             = "enableVisitors"
        case enableRealtime                             = "enableRealtime"
        
        //MARK: - optipush configuration
        case mobile                                     = "mobile"
        case optipushMetaData                           = "optipushMetaData"
        case registrationServiceOtherEndPoint           = "otherRegistrationServiceEndpoint"
        case registrationServiceRegistrationEndPoint    = "onlyRegistrationServiceEndpoint"
        case enableAdvertisingIdReport                  = "enableAdvertisingIdReport"
        case firebaseProjectKeys                        = "firebaseProjectKeys"
        case clientServiceProjectKeys                   = "clientsServiceProjectKeys"
        case appIds                                     = "appIds"
        case appId                                      = "appId"
        case ios                                        = "ios"
        case webApiKey                                  = "webApiKey"
        case dbUrl                                      = "dbUrl"
        case senderId                                   = "senderId"
        case storageBucket                              = "storageBucket"
        case projectId                                  = "projectId"
        case clientServiceAppNs                         = "ios.master.app"
        
        //MARK: - Realtime configuration
        case realtimeMetaData                           = "realtimeMetaData"
        case realtimeToken                              = "realtimeToken"
        case realtimeGateway                            = "realtimeGateway"
        
        //MARK:  - events configurations
        case events                                     = "events"
        case setAdvertisingId                           = "set_advertising_id"
        case id                                         = "id"
        case supportedOnOptitrack                       = "supportedOnOptitrack"
        case supportedOnRealTime                        = "supportedOnRealTime"
        case parameters                                 = "parameters"
        case advertisingId                              = "advertising_id"
        case optional                                   = "optional"
        case name                                       = "name"
        case type                                       = "type"
        case optiTrackDimensionId                       = "optiTrackDimensionId"
        case deviceId                                   = "device_id"
        case appNs                                      = "app_ns"
        case platform                                   = "platform"
        case stitchEvent                                = "stitch_event"
        case sourcePublicCustomerId                     = "source_public_customer_id"
        case sourceVisitorId                            = "source_visitor_id"
        case targetVsitorId                             = "target_visitor_id"
        case visitorId                                  = "visitor_id"
        case notificationDelivered                      = "notification_delivered"
        case timestamp                                  = "timestamp"
        case campignId                                  = "campaign_id"
        case actionSerial                               = "action_serial"
        case templateId                                 = "template_id"
        case engagementId                               = "engagement_id"
        case campaignType                               = "campaign_type"
        case notificationOpened                         = "notification_opened"
        case notificationDismissed                      = "notification_dismissed"
        case beforeSetUserId                            = "before_set_user_id"
        case originalVisitorId                          = "original_visitor_id"
        case realtimeOriginalVisitorId                  = "originalVisitorId"
        case userId                                     = "user_id"
        case realtimeUserId                             = "userId"
        case realtimeupdatedVisitorId                   = "updatedVisitorId"
        case optipushOptIn                              = "optipush_opt_in"
        case optipushOptOut                             = "optipush_opt_out"
        case afterSetUserId                             = "after_set_user_id"
        case setUserAgent                               = "user_agent_header_event"
        case userAgentHeader1                            = "user_agent_header1"
        case userAgentHeader2                            = "user_agent_header2"
        case setScreenVisit                             = "set_screen_visit"
        case screenName                                 = "screen_name"
    }
    
    enum Notification : String
    {
        case title                  = "title"
        case body                   = "content"
        case category               = "category"
        case dynamicLinks           = "dynamic_links"
        case ios                    = "ios"
        case campaignId             = "campaign_id"
        case actionSerial           = "action_serial"
        case templateId             = "template_id"
        case engagementId           = "engagement_id"
        case campaignType           = "campaign_type"
        case isOptipush             = "is_optipush"
        case collapseId             = "collapse_Key"
        case dynamikLink            = "dynamic_link"
        case isOptimoveSdkCommand   = "is_optimove_sdk_command"
        case command                = "command"
    }
    
    enum Topics:String
    {
        case fcmToken   = "fcmToken"
        case topics     = "topics"
    }
}

struct Values
{
    enum Notification:String
    {
        case reregister = "reregister"
        case ping       = "ping"
    }
}

struct NotificationCategoryIdentifiers
{
    static let dismiss    = "dismiss"
}

enum HttpHeader: String
{
    case contentType    = "Content-Type"
    case userAgent      = "User-Agent"
}

enum HttpMethod: String
{
    case get        = "GET"
    case post       = "POST"
    case head       = "HEAD"
    case put        = "PUT"
    case delete     = "DELETE"
    case options    = "OPTIONS"
    case connect    = "CONNECT"
}

enum MediaType: String
{
    case json = "application/json"
}

var TenantID : Int?
{
    get
    {
        return UserInSession.shared.siteID
    }
}
var Version :String?
{
    get
    {
        return UserInSession.shared.version
    }
}
var CustomerID :String? {
    get
    {
        return UserInSession.shared.customerID
    }
}
var VisitorID :String?
{
    get
    {
        return UserInSession.shared.visitorID
    }
}
var DeviceID : String
{
    get
    {
        return SHA1.hexString(from:UIDevice.current.identifierForVendor?.uuidString ?? "")!.replacingOccurrences(of: " ", with: "")
    }
}
var OSVersion : String
{
    get
    {
        return UIDevice.current.systemVersion
    }
}

typealias UserAgent = String

