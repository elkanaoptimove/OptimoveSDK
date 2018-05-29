
//  Optipush.swift
//  iOS-SDK
//
//  Created by Mobile Developer Optimove on 04/09/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import Foundation
import UserNotifications

final class OptiPush: OptimoveComponent
{
    //MARK: - Variables
    var metaData: OptipushMetaData!
    private var firebaseInteractor: FirebaseInteractor = FirebaseInteractor()
    private var registrar: RegistrationProtocol!
    
    override func performInitializationOperations()
    {
        if RunningFlagsIndication.isComponentRunning(.optiPush) {
            self.registerIfNeeded()
            self.retryFailedMbaasOperations()
           self.optInOutIfNeeded()
            firebaseInteractor.subscribeToTopics()
        }
    }
    
    func observerNotificaitonChange()
    {
        NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) { _ in
            self.optInOutIfNeeded()
        }
    }
    
    //MARK: - Internal methods
    func setup(firebaseMetaData:FirebaseProjectKeys,
               clientFirebaseMetaData:ClientsServiceProjectKeys,
               optipushMetaData:OptipushMetaData)
    {
        firebaseInteractor.setupFirebase(from: firebaseMetaData,
                                         clientFirebaseMetaData: clientFirebaseMetaData,
                                         delegate: self,
                                         endPointForTopics: optipushMetaData.registrationServiceOtherEndPoint)
        registrar = Registrar(optipushMetaData: optipushMetaData)
    }
    
    func application(didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        firebaseInteractor.handleRegistration(token:deviceToken)
    }
    
    func subscribeToTopic(topic:String, didSucceed: ((Bool)->())?  = nil)
    {
        if isEnable {
            firebaseInteractor.subscribeToTopic(topic:topic, didSucceed: didSucceed)
        }
    }
    func unsubscribeFromTopic(topic:String, didSucceed:  ((Bool)->())? = nil)
    {
        if isEnable {
            firebaseInteractor.unsubscribeFromTopic(topic: topic, didSucceed: didSucceed)
        }
    }
    
    func performRegistration()
    {
        registrar.register()
    }
}

extension OptiPush: OptimoveMbaasRegistrationHandling
{
    //MARK: - Protocol conformance
    func handleRegistrationTokenRefresh(token: String)
    {
        guard let oldFCMToken = UserInSession.shared.fcmToken else {
            handleFcmTokenReceivedForTheFirstTime(token)
            return
        }
        
        if (token != oldFCMToken) {
            registrar.unregister { (success) in
                if success {
                    self.updateFcmTokenWith(token)
                    self.performRegistration()
                    self.firebaseInteractor.subscribeToTopics()
                } else {
                    self.updateFcmTokenWith(token)
                }
            }
        }
    }
    
    func didReceiveFirebaseRegistrationToken(fcmToken:String)
    {
        firebaseInteractor.optimoveReceivedRegistrationToken(fcmToken)
    }
   
    private func handleFcmTokenReceivedForTheFirstTime(_ token: String)
    {
        OptiLogger.debug("Client receive a token for the first time")
        UserInSession.shared.fcmToken = token
        performRegistration()
        firebaseInteractor.subscribeToTopics()
    }
    
    private func updateFcmTokenWith(_ fcmToken:String)
    {
        UserInSession.shared.fcmToken = fcmToken
    }
    
}

extension OptiPush
{
    func registerIfNeeded()
    {
        if RunningFlagsIndication.isSdkRunning {
            if isNeedToPerformRegistration() {
                performRegistration()
            }
        }
    }
    
    private func isNeedToPerformRegistration() -> Bool
    {
        return UserInSession.shared.fcmToken != nil && UserInSession.shared.isRegistrationSuccess == false
    }
    
    private func retryFailedMbaasOperations()
    {
        registrar.retryFailedOperationsIfExist()
    }
}

extension OptiPush
{
    private func optInOutIfNeeded()
    {
        deviceStateMonitor.getStatus(of: .userNotification) { (granted) in
            if granted {
                self.handleNotificationAuthorized()
            } else {
                self.handleNotificationRejection()
            }
        }
    }
    private func handleNotificationAuthorizedAtFirstLaunch()
    {
        OptiLogger.debug("User Opt for first time")
        UserInSession.shared.isMbaasOptIn = true
    }
    private func handleNotificationAuthorized()
    {
        OptiLogger.debug("Notification authorized by user")
        guard let isOptIn = UserInSession.shared.isMbaasOptIn else
        { //Opt in on first launch
            handleNotificationAuthorizedAtFirstLaunch()
            return
        }
        if !isOptIn
        {
            OptiLogger.debug("SDK make opt in request")
            self.registrar.optIn()
            
        }
    }
    private func handleNotificationRejection()
    {
        OptiLogger.debug("Notification unauthorized by user")
        
        guard let isOptIn = UserInSession.shared.isMbaasOptIn else {
            //Opt out on first launch
            handleNotificationRejectionAtFirstLaunch()
            return
        }
        if isOptIn {
            OptiLogger.debug("SDK make opt OUT request")
            registrar.optOut()
            UserInSession.shared.isMbaasOptIn = false
        }
    }
    private func handleNotificationRejectionAtFirstLaunch()
    {
        OptiLogger.debug("User Opt out at first launch")
        guard UserInSession.shared.fcmToken != nil else {
            UserInSession.shared.isMbaasOptIn = false
            return
        }
        
        if UserInSession.shared.isRegistrationSuccess {
            UserInSession.shared.isMbaasOptIn = false
            self.registrar.optOut()
        }
    }
}
