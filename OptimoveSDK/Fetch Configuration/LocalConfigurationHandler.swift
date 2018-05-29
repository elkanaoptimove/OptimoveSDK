//
//  LocalConfigurationFetcher.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 27/02/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

class LocalConfigurationHandler {
    func get(completionHandler: @escaping ResultBlockWithData) {
        
        guard let fileName = UserInSession.shared.version else {return}
        
        let configFileName =  fileName + ".json"
        
        if let configData  = OptimoveFileManager.load(file: configFileName) {
            completionHandler(configData,nil)
        } else {
            completionHandler(nil,.emptyData)
        }
    }
}
