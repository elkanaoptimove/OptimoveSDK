//
//  RealTime.swift
//  OptimoveSDK
//
//  Created by Elkana Orbach on 11/04/2018.
//  Copyright © 2018 Optimove. All rights reserved.
//

import Foundation

class RealTime: OptimoveComponent
{
    var metaData:RealtimeMetaData!
    let realTimeQueue = DispatchQueue(label: "com.optimove.realtime")
    
    func set(userId: String, completionHandler:@escaping (Bool) -> Void)
    {
        realTimeQueue.async {
            guard RunningFlagsIndication.isComponentRunning(.realtime) else {
                OptiLogger.debug("Attempt to set user id when Realtime is not running")
                return
            }
            let parameters:[String:Any] = [Keys.Configuration.realtimeOriginalVisitorId.rawValue: VisitorID!,
                                            Keys.Configuration.realtimeUserId.rawValue:userId,
                                            Keys.Configuration.realtimeupdatedVisitorId.rawValue:MD5(userId).prefix(16)]
            let event = RealtimeEvent(tid: self.metaData.realtimeToken, cid: userId, visitorid: VisitorID!, eid: "1001", context: parameters)
            self.deviceStateMonitor.getStatus(of: .internet) { (online) in
                guard online else {
                    OptiLogger.warning("Device is offline, skip realtime event set user id")
                    return
                }
                let json = JSONEncoder()
                do {
                    let data = try json.encode(event)
                    NetworkManager.post(toUrl: URL(string:Optimove.sharedInstance.realTime.metaData.realtimeGateway+"reportEvent")!, json: data) { (data, error) in
                        if error != nil {
                            UserInSession.shared.realtimeSetUserIdFailed = true
                            completionHandler(false)
                        } else {
                            UserInSession.shared.realtimeSetUserIdFailed = false
                            OptiLogger.debug("real time set user id status:\(String(describing: String(data:data!,encoding:.utf8)!))")
                            completionHandler(true)
                        }
                    }
                } catch {
                    OptiLogger.error("could not encode realtime set user id request")
                    return
                }
            }
        }
    }
    func report(event: OptimoveEvent,withConfigs config: OptimoveEventConfig, completion:@escaping ()->())
    {
        guard isEnable else {
            OptiLogger.debug("Attempt to report event \(event.name) when Realtime was not enabled. Maybe check the configurations?")
            return
        }
        realTimeQueue.async {
            let rtEvent = RealtimeEvent(tid: self.metaData.realtimeToken, cid: UserInSession.shared.customerID, visitorid: VisitorID, eid: String(config.id), context: event.parameters)
            self.deviceStateMonitor.getStatus(of: .internet) { (online) in
                guard online else {
                    OptiLogger.warning("Device is offline, skip realtime event reporting \(event.name)")
                    completion()
                    return
                }
                guard !UserInSession.shared.realtimeSetUserIdFailed else {
                    self.set(userId: UserInSession.shared.customerID!) { (success) in
                        let json = JSONEncoder()
                        do {
                            let data = try json.encode(rtEvent)
                            NetworkManager.post(toUrl: URL(string:Optimove.sharedInstance.realTime.metaData.realtimeGateway+"reportEvent")!, json: data) { (data, error) in
                                if error != nil {
                                    OptiLogger.debug("\(event.name) failed to report on realtime servers")
                                } else {
                                    OptiLogger.debug("\(event.name) succeed to report on realtime servers")
                                }
                            }
                            completion()
                        } catch {
                            OptiLogger.error("could not encode realtime set user id request")
                            completion()
                            return
                        }
                    }
                    completion()
                    return
                }
                let json = JSONEncoder()
                do {
                    let data = try json.encode(rtEvent)
                    NetworkManager.post(toUrl: URL(string:Optimove.sharedInstance.realTime.metaData.realtimeGateway+"reportEvent")!, json: data) { (data, error) in
                        OptiLogger.debug("real time report status:\(String(describing: String(data:data!,encoding:.utf8)!))")
                        completion()
                    }
                } catch {
                    OptiLogger.error("could not encode realtime set user id request")
                    completion()
                    return
                }
            }
        }
    }
}
