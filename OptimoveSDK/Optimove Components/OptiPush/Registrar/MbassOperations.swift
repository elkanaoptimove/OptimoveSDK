//
//  MbassRequests.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 23/04/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation
enum MbaasOperations:String,Codable
{
    case registration = "registration_data"
    case unregistration = "unregistration_data"
    case optOut  = "opt_out"
    case optIn = "opt_in"
}
