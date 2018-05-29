//
//  OptimoveStateDelegate.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 25/04/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

struct OptimoveSuccessStateListenerWrapper
{
    weak var observer: OptimoveSuccessStateListener?
}

public protocol OptimoveSuccessStateListener: class
{
    func optimove(_ optimove: Optimove, didBecomeActiveWithMissingPermissions missingPermissions:[OptimoveDeviceRequirement] )
}

struct OptimoveSuccessStateDelegateWrapper {
     weak var observer: OptimoveSuccessStateDelegate?
}

@objc public protocol OptimoveSuccessStateDelegate: class
{
    @objc func optimove(_ optimove: Optimove, didBecomeActiveWithMissingPermissions missingPermissions:[Int] )
}
