//
//  Device.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 16/04/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import UIKit

class Device {
    static func evaluateUserAgent() -> UserAgent
    {
        let webView = UIWebView(frame: .zero)
        return webView.stringByEvaluatingJavaScript(from: "navigator.userAgent") ?? ""
    }
}
