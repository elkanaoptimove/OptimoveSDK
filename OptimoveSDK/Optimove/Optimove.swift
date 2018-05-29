//
//  Optimove.swift
//  iOS-SDK
//
//  Created by Mobile Developer Optimove on 04/09/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import UIKit
import UserNotifications

protocol OptimoveNotificationHandling
{
    func didReceiveRemoteNotification(userInfo:[AnyHashable : Any],
                                    didComplete:@escaping (UIBackgroundFetchResult) -> Void)
    func didReceive(response:UNNotificationResponse,
                                        withCompletionHandler completionHandler: @escaping (() -> Void))
}

@objc protocol OptimoveDeepLinkResponding
{
    @objc func register(deepLinkResponder responder: OptimoveDeepLinkResponder)
    @objc func unregister(deepLinkResponder responder: OptimoveDeepLinkResponder)
}

protocol OptimoveEventReporting:class
{
    func report(event: OptimoveEvent,completionHandler: (() -> Void)?)
    func dispatch()
}

/**
 The entry point of Optimove SDK.
 Initialize and configure Optimove using Optimove.sharedOptimove.configure.
 */
@objc public final class Optimove: NSObject
{
    //MARK: - Attributes
    
    var optiPush: OptiPush
    var optiTrack: OptiTrack
    var realTime: RealTime
    
    var eventWarehouse: OptimoveEventConfigsWarehouse?
    private let notificationHandler: OptimoveNotificationHandling
    private let deviceStateMonitor: OptimoveDeviceStateMonitor
    
    static var swiftStateDelegates: [ObjectIdentifier: OptimoveSuccessStateListenerWrapper] = [:]
    
    static var objcStateDelegate: [ObjectIdentifier: OptimoveSuccessStateDelegateWrapper] = [:]
    
    private let stateDelegateQueue = DispatchQueue(label: "com.optimove.sdk_state_delegates")
    
    private var optimoveTestTopic: String {
        return "test_ios_\(Bundle.main.bundleIdentifier ?? "")"
    }
    
    //MARK: - Deep Link
    
    private var deepLinkResponders = [OptimoveDeepLinkResponder]()
    
    var deepLinkComponents: OptimoveDeepLinkComponents? {
        didSet {
            guard  let dlc = deepLinkComponents else {
                return
            }
            for responder in deepLinkResponders {
                responder.didReceive(deepLinkComponent: dlc)
            }
        }
    }
    
    
    // MARK: - API
    
    
    //MARK: - Initializers
    /// The shared instance of optimove singleton
    @objc public static let sharedInstance: Optimove =
        {
            let instance = Optimove()
            return instance
    }()
    
    private init(notificationListener: OptimoveNotificationHandling = OptimoveNotificationHandler(),
                 deviceStateMonitor: OptimoveDeviceStateMonitor = OptimoveDeviceStateMonitor()) {
        self.deviceStateMonitor = deviceStateMonitor
        self.notificationHandler = notificationListener
        
        self.optiPush = OptiPush(deviceStateMonitor: deviceStateMonitor)
        self.optiTrack = OptiTrack(deviceStateMonitor: deviceStateMonitor)
        self.realTime = RealTime(deviceStateMonitor: deviceStateMonitor)
    }
    /// The starting point of the Optimove SDK
    ///
    /// - Parameter info: Basic client information received on the onboarding process with Optimove
    @objc public func configure(for tenantInfo: OptimoveTenantInfo)
    {
        configureLogger()
        OptiLogger.debug("Start Configure Optimove SDK")
        storeTenantInfo(tenantInfo)
        startNormalInitProcess { (sucess) in
            guard sucess else {
                OptiLogger.debug("Normal initializtion failed")
                return
            }
            OptiLogger.debug("Normal Initializtion success")
            self.didFinishInitializationSuccessfully()
        }
    }

    //MARK: - Private Methods
    
    /// stores the user information that was provided during configuration
    ///
    /// - Parameter info: user unique info
    private func storeTenantInfo(_ info: OptimoveTenantInfo)
    {
        UserInSession.shared.tenantToken = info.token
        UserInSession.shared.version = info.version
        UserInSession.shared.configurationEndPoint = info.url
        UserInSession.shared.isClientHasFirebase = info.hasFirebase
        UserInSession.shared.isClientUseFirebaseMessaging = info.useFirebaseMessaging
        OptiLogger.debug("stored user info in local storage: \ntoken:\(info.token)\nversion:\(info.version)\nend point:\(info.url)\nhas firebase:\(info.hasFirebase)\nuse Messaging: \(info.useFirebaseMessaging)")
    }
    
    private func configureLogger()
    {
        OptiLogger.configure()
    }
}

// MARK: - Initialization API
extension Optimove
{
    func startNormalInitProcess(didSucceed: @escaping ResultBlockWithBool)
    {
        OptiLogger.debug("Start Optimove component initialization from remote")
        if RunningFlagsIndication.isSdkRunning  {
            OptiLogger.error("Skip normal initializtion since SDK already running")
            didSucceed(true)
            return
        }
        OptimoveSDKInitializer(deviceStateMonitor: deviceStateMonitor).initializeFromRemoteServer { success in
            guard success else {
                OptimoveSDKInitializer(deviceStateMonitor: self.deviceStateMonitor).initializeFromLocalConfigs { success in
                    didSucceed(success)
                }
                return
            }
            didSucceed(success)
        }
    }
    
    func startUrgentInitProcess(didSucceed: @escaping ResultBlockWithBool)
    {
        OptiLogger.debug("Start Optimove urgent initiazlition process")
        if RunningFlagsIndication.isSdkRunning  {
            OptiLogger.error("Skip urgent initializtion since SDK already running")
            didSucceed(true)
            return
        }
        OptimoveSDKInitializer(deviceStateMonitor: self.deviceStateMonitor).initializeFromLocalConfigs { success in
            didSucceed(success)
        }
    }
    
    func didFinishInitializationSuccessfully()
    {
        RunningFlagsIndication.isInitializerRunning = false
        RunningFlagsIndication.isSdkRunning = true
        for (_,delegate) in Optimove.swiftStateDelegates {
            delegate.observer?.optimove(self, didBecomeActiveWithMissingPermissions: deviceStateMonitor.getMissingPermissions())
        }
    }
}


// MARK: - SDK state observing
//TODO: expose to  @objc
extension Optimove
{
      public func registerSuccessStateListener(_ delegate: OptimoveSuccessStateListener)
     {
        if RunningFlagsIndication.isSdkRunning {
            delegate.optimove(self, didBecomeActiveWithMissingPermissions: self.deviceStateMonitor.getMissingPermissions())
            return
        }
        stateDelegateQueue.async {
            Optimove.swiftStateDelegates[ObjectIdentifier(delegate)] = OptimoveSuccessStateListenerWrapper(observer: delegate)
        }
    }
    
     public func unregisterSuccessStateListener(_ delegate: OptimoveSuccessStateListener)
     {
        stateDelegateQueue.async {
            Optimove.swiftStateDelegates[ObjectIdentifier(delegate)] = nil
        }
    }
    
    @available(swift, obsoleted: 1.0)
    @objc public func registerSuccessStateDelegate(_ delegate:OptimoveSuccessStateDelegate) {
        if RunningFlagsIndication.isSdkRunning {
            delegate.optimove(self, didBecomeActiveWithMissingPermissions: self.deviceStateMonitor.getMissingPersmissions())
            return
        }
        stateDelegateQueue.async {
            Optimove.objcStateDelegate[ObjectIdentifier(delegate)] = OptimoveSuccessStateDelegateWrapper(observer: delegate)
        }
    }
    @available(swift, obsoleted: 1.0)
    @objc public func unregisterSuccessStateDelegate(_ delegate:OptimoveSuccessStateDelegate)
    {
        stateDelegateQueue.async {
            Optimove.objcStateDelegate[ObjectIdentifier(delegate)] = nil
        }
    }
}

// MARK: - Notification related API
extension Optimove
{
    /// Validate user notification permissions and sends the payload to the message handler
    ///
    /// - Parameters:
    ///   - userInfo: the data payload as sends by the the server
    ///   - completionHandler: an indication to the OS that the data is ready to be presented by the system as a notification
    @objc public func didReceiveRemoteNotification(userInfo: [AnyHashable: Any],
                                                      didComplete: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        OptiLogger.debug("Receive Remote Notification")
        guard isOptipushNotification(userInfo) else {
            return false
        }
        notificationHandler.didReceiveRemoteNotification(userInfo: userInfo,
                                                       didComplete: didComplete)
        return true
    }
    
    /// Report user response to optimove notifications and send the client the related deep link to open
    ///
    /// - Parameters:
    ///   - response: The user response
    ///   - completionHandler: Indication about the process ending
    @objc public func didReceive(response:UNNotificationResponse,
                                                     withCompletionHandler completionHandler: @escaping () -> Void) -> Bool
    {
        guard isOptipushNotification(response.notification.request.content.userInfo) else {
            return false
        }
        notificationHandler.didReceive(response: response,
                                                           withCompletionHandler: completionHandler)
        return true
    }
}



// MARK: - OptiPush related API
extension Optimove
{
    /// Request to handle APNS <-> FCM regisration process
    ///
    /// - Parameter deviceToken: A token that was received in the appDelegate callback
    @objc public func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        optiPush.application(didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    /// Request to subscribe to test campaign topics
    @objc public func startTestMode() {
        registerToOptipushTopic(optimoveTestTopic)
        
    }
    
    /// Request to unsubscribe from test campaign topics
    @objc public func stopTestMode() {
        unregisterFromOptipushTopic(optimoveTestTopic)
    }
    
    /// Request to register to topic
    ///
    /// - Parameter topic: The topic name
    @objc public func registerToOptipushTopic(_ topic: String, didSucceed: ((Bool)->())? = nil)
    {
        if RunningFlagsIndication.isComponentRunning(.optiPush) {
                optiPush.subscribeToTopic(topic: topic,didSucceed: didSucceed)
        }
    }
    
    /// Request to unregister from topic
    ///
    /// - Parameter topic: The topic name
    @objc public func unregisterFromOptipushTopic(_ topic: String,didSucceed: ((Bool)->())? = nil)
    {
        if RunningFlagsIndication.isComponentRunning(.optiPush) {
            optiPush.unsubscribeFromTopic(topic: topic,didSucceed: didSucceed)
        }
    }
    
    @objc public func optimove(didReceiveFirebaseRegistrationToken fcmToken: String )
    {
        optiPush.didReceiveFirebaseRegistrationToken(fcmToken: fcmToken)
    }
    
    func performRegistration()
    {
        if RunningFlagsIndication.isComponentRunning(.optiPush)
        {
            optiPush.performRegistration()
        }
    }
}

extension Optimove: OptimoveDeepLinkResponding
{
    @objc public func register(deepLinkResponder responder: OptimoveDeepLinkResponder)
    {
        if let dlc = self.deepLinkComponents {
            responder.didReceive(deepLinkComponent: dlc)
        } else {
            deepLinkResponders.append(responder)
        }
    }
    
    @objc public func unregister(deepLinkResponder responder: OptimoveDeepLinkResponder)
    {
        if let index = self.deepLinkResponders.index(of: responder) {
            deepLinkResponders.remove(at: index)
        }
    }
}

extension Optimove:OptimoveEventReporting
{
    func report(event: OptimoveEvent, completionHandler: (() -> Void)? = nil)
    {
        guard let config = eventWarehouse?.getConfig(ofEvent: event) else {
            OptiLogger.error("configurations for event: \(event.name) are missing")
            return
        }
        let eventValidationError = OptimoveEventValidator().validate(event: event, withConfig: config)
        guard eventValidationError == nil else {
            OptiLogger.error("report event is invalid with error \(eventValidationError.debugDescription)")
            return
        }
        let group = DispatchGroup()
        if config.supportedOnOptitrack {
            group.enter()
            optiTrack.report(event: event, withConfigs: config) {
                group.leave()
            }
        }
        
        if config.supportedOnRealTime {
            guard RunningFlagsIndication.isComponentRunning(.realtime) else {return}
            group.enter()
            realTime.report(event: event, withConfigs: config) {
                group.leave()
            }
        }
         group.notify(queue: .main) {
            completionHandler?()
        }
    }
    
    @objc public func dispatchNow()
    {
        dispatch()
    }

    func dispatch()
    {
        if RunningFlagsIndication.isSdkRunning {
            optiTrack.dispatchNow()
        }
    }
}

// MARK: - optiTrack related API
extension Optimove {
    /// validate the permissions of the client to use optitrack component and if permit sends the report to the apropriate handler
    ///
    /// - Parameters:
    ///   - event: optimove event object
    @objc public func reportEvent(_ event: OptimoveEvent)
    {
        if optiTrack.isEnable {
            report(event: event)
        }
    }

    @objc public func reportScreenVisit(viewControllersIdentifiers: [String], url: URL? = nil) {
        optiTrack.setScreenEvent(viewControllersIdentifiers: viewControllersIdentifiers, url: url)
    }

    /// validate the permissions of the client to use optitrack component and if permit sends the report to the apropriate handler
    ///
    /// - Parameters:
    ///   - event: optimove event object
    
    @objc(reportEventWithEvent:)
    public func objc_reportEvent(event: OptimoveEvent) {
        self.report(event: event)
    }
}

// MARK: - set user id API
extension Optimove {

    /// validate the permissions of the client to use optitrack component and if permit validate the userID content and sends:
    /// - conversion request to the DB
    /// - new customer registraion to the registration end point
    ///
    /// - Parameter userID: the client unique identifier
    @objc public func set(userID: String)
    {
        set(userID: userID) { (success) in
            
        }
    }
    
    func set(userID: String, completionHandler: ((Bool) -> Void)?)
    {
        guard OptimoveEventValidator().validate(userId: userID) else {
            OptiLogger.error("user id \(userID) is not valid")
            return
        }
        let userId = userID.trimmingCharacters(in: .whitespaces)
        
        if UserInSession.shared.customerID == nil {
            UserInSession.shared.customerID = userId
            UserInSession.shared.isRegistrationSuccess = false
        } else if userId != UserInSession.shared.customerID {
            OptiLogger.debug("user id changed from \(String(describing: UserInSession.shared.customerID)) to \(userId)" )
            UserInSession.shared.customerID = userId
            UserInSession.shared.isRegistrationSuccess = false
        } else {
            return
        }
        let concurrentSetUserIdQueue = DispatchQueue(label: "com.optimove.setUserId", attributes: .concurrent)
        concurrentSetUserIdQueue.async {
            self.optiTrack.set(userID: userId)
        }
        concurrentSetUserIdQueue.async {
            self.optiPush.performRegistration()
        }
        concurrentSetUserIdQueue.async {
            self.realTime.set(userId: userId ) { status in completionHandler?(status)}
        }
    }
}

//MARK: RealtimeAdditional events
extension Optimove
{
    @objc public func registerUser(email:String, userId:String)
    {
        set(userID: userId) { (succeed) in
            if succeed {
                self.setUserEmail(email: email)
            }
        }
    }
    @objc public func setUserEmail(email:String)
    {
        guard  isValidEmail(email: email) else {
            OptiLogger.debug("email is not valid")
            return
        }
        report(event: SetEmailEvent(email: email))
    }
    private func isValidEmail(email:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

// MARK: - Helper Methods
extension Optimove
{
    private func isOptipushNotification(_ userInfo: [AnyHashable : Any]) -> Bool
    {
        return userInfo[Keys.Notification.isOptipush.rawValue] as? String == "true" || userInfo[Keys.Notification.isOptimoveSdkCommand.rawValue] as? String == "true"
    }
}
