//
//  FirebaseProjectKeys.swift
//  WeAreOptimove
//
//  Created by Elkana Orbach on 10/05/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

class FirebaseProjectKeys:FirebaseKeys
{
    var appid:String
    
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let appIds = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .appIds )
        let ios = try appIds.nestedContainer(keyedBy: CK.self, forKey: .ios)
        let key = Bundle.main.bundleIdentifier!
        appid = try ios.decode(String.self, forKey: CK(stringValue:key)!)
        try super.init(from: decoder)
    }
}
