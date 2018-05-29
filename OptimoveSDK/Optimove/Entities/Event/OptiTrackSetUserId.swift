//
//  OptiTrackSetUserId.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 13/05/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation


class SetUserId :OptimoveEvent,OptimovePredefinedEvent
{
    var name: String
    {
        return ""
    }
    var parameters: [String : Any]
    {
        guard let visitorId = VisitorID, let customerId = CustomerID else {
            return [Keys.Configuration.originalVisitorId.rawValue   : VisitorID as Any,
                    Keys.Configuration.userId.rawValue              : CustomerID as Any]
        }
        return [Keys.Configuration.originalVisitorId.rawValue   : visitorId,
                Keys.Configuration.userId.rawValue              : customerId]
    }
}

class BeforeSetUserId: SetUserId
{
    override var name: String
    {
        return Keys.Configuration.beforeSetUserId.rawValue
    }
}

class AfterSetUserId: SetUserId
{
    override var name: String
    {
        return Keys.Configuration.afterSetUserId.rawValue
    }
}
