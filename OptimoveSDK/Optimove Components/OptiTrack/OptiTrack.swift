//
//  Optitrack.swift
//  iOS-SDK
//
//  Created by Mobile Developer Optimove on 04/09/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import Foundation
import OptiTrackCore

protocol OptimoveAnalyticsProtocol
{
    func report(event: OptimoveEvent,withConfigs config: OptimoveEventConfig,completionHandler: (() -> Void)?)
    func setScreenEvent(viewControllersIdentifiers:[String],url: URL?)
    func set(userID: String)
    func dispatchNow()
}

final class OptiTrack:OptimoveComponent
{
    //MARK: - Internal Variables
    var metaData: OptitrackMetaData!
    var queue = OptimoveQueue()
    var tracker: MatomoTracker!
    let evetReportingQueue      = DispatchQueue(label: "com.optimove.optitrack",
                                                qos: .userInitiated,
                                                attributes: [],
                                                autoreleaseFrequency: .inherit,
                                                target: nil)
    var openApplicationTime     : TimeInterval = Date().timeIntervalSince1970
    
    //MARK: - Internal Methods
    func storeVisitorId()
    {
        if UserInSession.shared.visitorID == nil {
            UserInSession.shared.visitorID =  tracker.visitorId
        }
    }
    
    override func performInitializationOperations()
    {
        if RunningFlagsIndication.isComponentRunning(.optiTrack) {
            self.storeVisitorId()
            self.reportPendingEvents()
            self.reportIdfaIfAllowed()
            self.reportUserAgent()
            self.reportSetUserIdIfNeeded()
            self.reportOptInOutIfNeeded()
            self.observerNotificaitonChange()
            if UIApplication.shared.applicationState == .active {
                self.reportAppOpen()
            }
            self.trackAppOpened()

            self.observeEnterToBackgroundMode()
        }
    }
    private func observeEnterToBackgroundMode()
    {
        NotificationCenter.default.addObserver(forName: .UIApplicationDidEnterBackground,
                                               object: self,
                                               queue: .main) { (notification) in
                                                self.dispatchNow()
        }
    }
}

extension OptiTrack: OptimoveAnalyticsProtocol
{
    func report(event: OptimoveEvent,withConfigs config: OptimoveEventConfig, completionHandler: (() -> Void)? = nil)
    {
        let group = DispatchGroup()
        group.enter()
        if event is OptimovePredefinedEvent {
            guard RunningFlagsIndication.isComponentRunning(.optiTrack) else { return }
            evetReportingQueue.async {
                self.handleReport(event: event, withConfigs: config) {
                    group.leave()
                }
            }
        } else {
            guard isEnable else { return }
            evetReportingQueue.async {
                self.handleReport(event: event, withConfigs: config)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completionHandler?()
        }
    }
    
    private func handleReport(event: OptimoveEvent,withConfigs config: OptimoveEventConfig, completionHandler: (() -> Void)? = nil)
    {
        DispatchQueue.main.async {
            var dimensionsIDs: [Int] = []
            dimensionsIDs.append(self.metaData.eventIdCustomDimensionId)
            self.tracker.set(dimension: CustomDimension(index: self.metaData.eventIdCustomDimensionId, value: String(config.id)))
            dimensionsIDs.append(self.metaData.eventNameCustomDimensionId)
            self.tracker.set(dimension: CustomDimension(index: self.metaData.eventNameCustomDimensionId, value: event.name))
            
            for (name,value) in event.parameters
            {
                if let optitrackDimensionID = config.parameters[name]?.optiTrackDimensionId
                {
                    dimensionsIDs.append(optitrackDimensionID)
                    self.tracker.set(dimension: CustomDimension(index: optitrackDimensionID, value: String(describing: value)))
                }
            }
            self.tracker.track(eventWithCategory: self.metaData.eventCategoryName,
                               action: event.name,
                               name: nil,
                               number: nil,
                               url:nil)
            
            for index in dimensionsIDs
            {
                self.tracker.remove(dimensionAtIndex: index)
            }
            completionHandler?()
        }
    }
    
    func setScreenEvent(viewControllersIdentifiers:[String],url: URL?)
    {
        guard let active = RunningFlagsIndication.componentsRunningStates[.optiTrack] else {return}
        if active && isEnable {
            evetReportingQueue.async {
                OptiLogger.debug("report screen event of \(viewControllersIdentifiers)")
                DispatchQueue.main.async {
                    self.tracker?.track(view: viewControllersIdentifiers, url: url)
                }
            }
        }
    }
    
    func set(userID: String)
    {
        guard RunningFlagsIndication.isSdkRunning else {
            UserInSession.shared.isSetUserIdSucceed = false
            return
        }
        OptiLogger.debug("report set user id: \(userID)")
        Optimove.sharedInstance.report(event: BeforeSetUserId()) {
            self.tracker.userId = userID
            Optimove.sharedInstance.report(event: AfterSetUserId()) {
                self.dispatchNow()
                UserInSession.shared.isSetUserIdSucceed = true
            }
        }
    }
    
    func dispatchNow()
    {
        if RunningFlagsIndication.isComponentRunning(.optiTrack) {
            OptiLogger.debug("user asked to dispatch")
            tracker.dispatch()
        } else {
            OptiLogger.debug("optitrack component not running")
        }
    }
    
    private func reportIdfaIfAllowed()
    {
        guard metaData.enableAdvertisingIdReport == true else {return}
        self.deviceStateMonitor.getStatus(of: .advertisingId) { (isAllowed) in
            if isAllowed {
                OptiLogger.debug("report IDFA")
                Optimove.sharedInstance.report(event: SetAdvertisingId())
            }
        }
    }
    
    func observerNotificaitonChange()
    {
        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) { _ in
            self.reportOptInOutIfNeeded()
            
        }
    }
    
    private func reportUserAgent()
    {
        OptiLogger.debug("report User Agent")
        let userAgent = Device.evaluateUserAgent()
        Optimove.sharedInstance.report(event: SetUserAgent(userAgent: userAgent))
    }
    
    private func reportSetUserIdIfNeeded()
    {
        if isNeedToReportSetUserId() {
            self.set(userID: UserInSession.shared.customerID!)
        }
    }
    
    private func isOptInOutStateChanged(with newState:Bool) -> Bool
    {
        return newState != UserInSession.shared.isOptiTrackOptIn ? true : false
    }
    
    private func reportOptInOutIfNeeded()
    {
        deviceStateMonitor.getStatus(of: .userNotification) { (granted) in
            if self.isOptInOutStateChanged(with: granted) {
                if granted {
                    Optimove.sharedInstance.report(event: OptipushOptIn()) {
                        self.dispatchNow()
                        UserInSession.shared.isOptiTrackOptIn = true
                    }
                } else {
                    Optimove.sharedInstance.report(event: OptipushOptOut()) {
                        self.dispatchNow()
                        UserInSession.shared.isOptiTrackOptIn = false
                    }
                }
            }
        }
    }
    
    private func trackAppOpened() {
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillEnterForeground,
                                               object: nil,
                                               queue: .main) { (notification) in
                                                if Date().timeIntervalSince1970 - self.openApplicationTime > 1800 {
                                                    self.reportAppOpen()
                                                }
        }
    }
    
    private func isNeedToReportSetUserId() -> Bool
    {
        return UserInSession.shared.isSetUserIdSucceed == false && UserInSession.shared.customerID != nil
    }
}

extension OptiTrack
{
    private func reportPendingEvents()
    {
        if RunningFlagsIndication.isComponentRunning(.optiTrack) {
            if let jsonEvents =  OptimoveFileManager.load(file: "pendingOptimoveEvents.json") {
                let decoder = JSONDecoder()
                let events = try! decoder.decode([Event].self, from: jsonEvents)
                
                //Since all stored events are already matomo events type, no need to do the entire process
                events.forEach { (event) in
                    DispatchQueue.main.async {
                        self.tracker.track(event)
                    }
                }
            }
        }
    }
    
    
    private func reportAppOpen()
    {
        Optimove.sharedInstance.report(event: AppOpened())
        openApplicationTime = Date().timeIntervalSince1970
    }
}
