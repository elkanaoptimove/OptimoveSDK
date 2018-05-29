//
//  RemoteConfigurationFetcher.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 27/02/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

class RemoteConfigurationHandler {
    
    func get(completionHandler: @escaping ResultBlockWithData)
    {
        self.downloadConfigurations { (data,error) in
            completionHandler(data,error)
        }
    }
    
    private func downloadConfigurations(didComplete: @escaping ResultBlockWithData)
    {
        if let tenantToken = UserInSession.shared.tenantToken, let version = Version
        {
            let path = "\(UserInSession.shared.configurationEndPoint)/\(tenantToken)/\(version).json"
            
            OptiLogger.debug("Connect to \(path) to retreive configuration file ")
            
            if let url = URL(string: path)
            {
                NetworkManager.get(from: url) {
                    (response,error)  in
                    didComplete(response,error)
                }
            }
        }
    }
}
