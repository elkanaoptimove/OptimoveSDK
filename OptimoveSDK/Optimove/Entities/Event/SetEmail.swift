//
//  SetEmail.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 13/05/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation
class SetEmailEvent: OptimoveEvent,OptimovePredefinedEvent
{
    let email:String
    init(email:String) {
        self.email = email
    }
    var name: String {
        return  "Set_email_event"
    }
    
    var parameters: [String : Any] {
        return ["email":email]
    }
    
    
}
