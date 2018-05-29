//
//  Fetchable.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 27/02/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

protocol Fetchable
{
    func fetch(completionHandler: @escaping ResultBlockWithBool)
}


