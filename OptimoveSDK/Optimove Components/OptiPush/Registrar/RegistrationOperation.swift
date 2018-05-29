//
//  RegistrationOperation.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 23/04/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation


class MbaasOperation {
    var tenantId: Int
    init() {
        tenantId = TenantID ?? -1
    }
}

//class RegistrationOperation: MbaasOperation {
//    var iOSToken: [String:Any]
//
//    override init(iOsToken:[String:Any]) {
//        super.init()
//        self.iOSToken = iOsToken
//    }
//}
//
//class CustomerRegistrationOperation: RegistrationOperation {
//    var publicCustomerId:String
//    var isConversion:Bool
//    var originalVisitorId:String
//
//    override init(iOsToken: [String : Any], isConversion:Bool, publicCustomerId:String = CustomerID,
//                  originalVisitorId:String = VisitorID) {
//        super.init(iOsToken: iOsToken)
//        self.publicCustomerId = publicCustomerId
//        self.originalVisitorId = originalVisitorId
//        self.isConversion = isConversion
//    }
//}
//
//class VisitorRegistrationOperation: RegistrationOperation {
//    var visitorId:String
//    override init(iOsToken: [String : Any],visitorId:String) {
//        super.init(iOsToken: iOsToken)
//        self.visitorId = visitorId
//    }
//}
