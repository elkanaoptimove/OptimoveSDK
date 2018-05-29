//
//  OptimoveError.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 28/12/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import Foundation

public enum OptimoveError:Error
{
    case noError 
    case error(String)
    case noNetwork
    case statusCodeInvalid
    case noPermissions
    case invalidEvent
    case optipushServerNotAvailable
    case optipushComponentUnavailable
    case optiTrackComponentUnavailable
    case illegalParameterLength
    case mismatchParamterType
    case mandatoryParameterMissing
    case cantStoreFileInLocalStorage
    case canNotParseData
    case emptyData
}
