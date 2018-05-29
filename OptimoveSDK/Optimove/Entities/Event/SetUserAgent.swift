//
//  SetUserAgent.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 13/05/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation
class SetUserAgent: OptimoveEvent,OptimovePredefinedEvent
{
    init(userAgent:String){
        if userAgent.count <= 255 {
            self.userAgent1 = userAgent
            return
        }
        let firstIndex = userAgent.startIndex
        let last1Index = userAgent.index(firstIndex, offsetBy: 254)
        
        self.userAgent1 =
            String(userAgent[firstIndex...last1Index])
        self.userAgent2 = userAgent
        self.userAgent2?.removeSubrange(firstIndex...last1Index)
        
    }
    var userAgent1:String
    var userAgent2:String?
    
    
    var name: String {return Keys.Configuration.setUserAgent.rawValue}
    
    var parameters: [String : Any]
    {
        var paramters = [Keys.Configuration.userAgentHeader1.rawValue: self.userAgent1]
        if userAgent2 != nil {
            paramters[Keys.Configuration.userAgentHeader2.rawValue] = self.userAgent2!
        }
        return paramters
    }
}
