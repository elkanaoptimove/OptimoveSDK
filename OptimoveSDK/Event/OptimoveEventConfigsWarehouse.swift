//
//  OptimoveEventConfigsWarehouse.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 17/04/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

struct OptimoveEventConfigsWarehouse {
    
    private let eventsConfigs: [String:OptimoveEventConfig]
    
    init(from tenantConfig:TenantConfig)
    {
        OptiLogger.debug("Initialize events warehouse")
        eventsConfigs = tenantConfig.events
        OptiLogger.debug("Finished initialization of events warehouse")
    }
    
    func getConfig(ofEvent event: OptimoveEvent) -> OptimoveEventConfig? {
        return eventsConfigs[event.name]
    }
}
