//
//  OptiPushConfigurator.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 04/03/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

class OptiPushConfigurator: OptimoveComponentConfigurator<OptiPush>{
    
    required init(component: OptiPush) {
        super.init(component: component)
    }
    
    override func setEnabled(from tenantConfig:TenantConfig) {
        component.isEnable = tenantConfig.enableOptipush
    }
    
    override func getRequirements() -> [OptimoveDeviceRequirement]
    {
        return [.userNotification,.internet]
    }
    
    
    override func executeInternalConfigurationLogic(from tenantConfig:TenantConfig,didComplete:@escaping ResultBlockWithBool)
    {
       OptiLogger.debug("Configure Optipush")
        guard let optipushMetadata = tenantConfig.optipushMetaData,
            let firebaseProjectKeys = tenantConfig.firebaseProjectKeys,
            let clientsServiceProjectKeys = tenantConfig.clientsServiceProjectKeys else {
                OptiLogger.error("👎🏻 Optipush configurations invalid")
                didComplete(false)
                return
        }
        setMetaData(optipushMetadata)
        component.setup(firebaseMetaData: firebaseProjectKeys,
                        clientFirebaseMetaData: clientsServiceProjectKeys,
                        optipushMetaData: optipushMetadata )
        OptiLogger.debug("👍🏻 OptiPush configuration succeed")
        didComplete(true)
    }
    
    private func setMetaData(_ optipushMetadata: OptipushMetaData) {
        component.metaData = optipushMetadata
    }
    
}
