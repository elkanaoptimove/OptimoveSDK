//
//  NetworkManager.swift
//  iOS-SDK
//
//  Created by Mobile Developer Optimove on 04/09/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import Foundation
import SystemConfiguration

let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)

//  MARK: Closure typealias
public typealias ResultBlock = () -> Void
public typealias ResultBlockWithError = (OptimoveError?) -> Void
public typealias ResultBlockWithErrors = ([OptimoveError]) -> Void
public typealias ResultBlockWithBool = (Bool) -> Void
public typealias ResultBlockWithData = (Data?,OptimoveError?) -> Void


class NetworkManager
{
    static func get(from url:URL, optimoveResponse:@escaping ResultBlockWithData)
    {
        let task = URLSession.shared.dataTask(with: url)
        { (data, response, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    OptiLogger.debug("configuration request error:\(error.debugDescription)")
                    optimoveResponse(nil,.error("error"))
                    return
                }
                
                guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                    OptiLogger.debug("Issue with configuration response")
                    optimoveResponse(nil,.statusCodeInvalid)
                    return
                }
                
                OptiLogger.debug("Configuration file arrived 😃 ")
                optimoveResponse(data,nil)
            }
        }
        task.resume()
    }
    
    static func post(toUrl url:URL,json:Data, optimoveResponse: @escaping ResultBlockWithData)
    {
        func generateRequest(toUrl url:URL) -> URLRequest
        {
            var request = URLRequest(url: url)
            request.timeoutInterval = 60
            request.httpMethod = HttpMethod.post.rawValue
            request.setValue(MediaType.json.rawValue,
                             forHTTPHeaderField: HttpHeader.contentType.rawValue)
            return request
        }
        
        var request = generateRequest(toUrl: url)
        request.httpBody = json
        let task = URLSession.shared.dataTask(with: request)
        { (data, response, error) in
            guard error == nil else {
                optimoveResponse(nil,OptimoveError.error(error.debugDescription))
                return
            }
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                optimoveResponse(nil,OptimoveError.statusCodeInvalid)
                return
            }
            if let data = data {
                optimoveResponse(data,nil)
            }
        }
        task.resume()
    }
}

