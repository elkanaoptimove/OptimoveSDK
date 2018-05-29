//
//  Registrar.swift
//  OptimoveSDKDev
//
//  Created by Mobile Developer Optimove on 11/09/2017.
//  Copyright © 2017 Optimove. All rights reserved.
//

import Foundation

protocol RegistrationProtocol:class
{
    func register()
    func unregister(didComplete: @escaping ResultBlockWithBool)
    func optIn()
    func optOut()
    func retryFailedOperationsIfExist()
}

class Registrar
{
    //MARK: - Internal Variables
    private var registrationEndPoint: String
    private var reportEndPoint: String
    
    //MARK: - Constructor
    init(optipushMetaData: OptipushMetaData)
    {
        OptiLogger.debug("Start Initialize Registrar")
        self.registrationEndPoint = optipushMetaData.registrationServiceRegistrationEndPoint
        if registrationEndPoint.last != "/"  {
            registrationEndPoint.append("/")
        }
        self.reportEndPoint = optipushMetaData.registrationServiceOtherEndPoint
        if reportEndPoint.last != "/"  {
            reportEndPoint.append("/")
        }
        OptiLogger.debug("Finish Initialize Registrar")
    }
    
    //MARK: - Private Methods
    
    private func backupRequest(_ mbaasRequestBody: MbaasRequestBody) {
        let path = getStoragePath(for: mbaasRequestBody.operation)
        
        if let json = try? JSONEncoder().encode(mbaasRequestBody){
            OptimoveFileManager.save(data:json , toFileName: path)
        } else {
            OptiLogger.error("Could not encode user push token: \(mbaasRequestBody)")
        }
    }
    
    private func clearBackupRequest(_ mbaasRequestBody: MbaasRequestBody) {
        let path = getStoragePath(for: mbaasRequestBody.operation)
        OptimoveFileManager.delete(file: path)
    }
    
    private func getMbaasPath(for userPushToken: MbaasRequestBody) -> String {
        let suffix = userPushToken.publicCustomerId == nil ? "Visitor" : "Customer"
        switch userPushToken.operation {
        case .registration:
            return  "\(registrationEndPoint)register\(suffix)"
        case .unregistration:
            return "\(reportEndPoint)unregister\(suffix)"
        case .optIn: fallthrough
        case .optOut:
            return "\(reportEndPoint)optInOut\(suffix)"
        }
    }
    
    private func getStoragePath(for operation: MbaasOperations) -> String {
        switch operation {
        case .registration:
            return "register_data.json"
        case .unregistration:
            return "unregister_data.json"
        case .optIn: fallthrough
        case .optOut:
            return "opt_in_out_data.json"
        }
    }
    
    //MARK: - Internal Methods
    private func setSuccesFlag(succeed: Bool, for operation:MbaasOperations)
    {
        switch operation {
        case .optIn, .optOut:
            UserInSession.shared.isOptRequestSuccess = succeed
        case .registration:
            UserInSession.shared.isRegistrationSuccess = succeed
        case .unregistration:
            UserInSession.shared.isUnregistrationSuccess = succeed
        }
    }
    
    private func retryFailedOperation(using json: Data) {
        guard let mbaasRequestBody = try? JSONDecoder().decode(MbaasRequestBody.self, from: json),
            let mbaasJson = mbaasRequestBody.toMbaasJsonBody()
            else {
            // PRINT LOG HERE
            
            return
        }
        let url = URL(string:  getMbaasPath(for: mbaasRequestBody))!
        
        OptiLogger.debug("send retry request to :\(url.path)")
        NetworkManager.post(toUrl: url, json: mbaasJson) { (data, error) in
            guard error == nil else {
                self.backupRequest(mbaasRequestBody)
                return
            }
            self.clearBackupRequest(mbaasRequestBody)
            self.setSuccesFlag(succeed: true, for: mbaasRequestBody.operation)
            if mbaasRequestBody.operation == .unregistration {
                self.register()
            }
        }
    }
    
    func retryFailedOperationsIfExist() {
        if (!UserInSession.shared.isUnregistrationSuccess) {
            let path = getStoragePath(for: .unregistration)
            if let json = OptimoveFileManager.load(file: path) {
                self.retryFailedOperation(using: json)
            }
        } else if (!UserInSession.shared.isRegistrationSuccess) {
            let path = getStoragePath(for: .registration)
            if let json = OptimoveFileManager.load(file: path) {
                self.retryFailedOperation(using: json)
            }
        }
        if (!UserInSession.shared.isOptRequestSuccess) {
            let path = getStoragePath(for: .optIn) // optIn and optOut share the same backup file
            if let json = OptimoveFileManager.load(file: path) {
                self.retryFailedOperation(using: json)
            }
        }
    }
}

extension Registrar: RegistrationProtocol
{
    func register()
    {
        guard VisitorID != nil else { return }
        let mbaasRequest = MbaasRequestBuilder(operation: .registration)
            .setUserInfo(visitorId: VisitorID!, customerId: CustomerID)
            .build()
        let url = URL(string:  getMbaasPath(for: mbaasRequest))!
        guard let json = mbaasRequest.toMbaasJsonBody() else {
            OptiLogger.error("could not build Json object of \(mbaasRequest.operation)")
            return
        }

        NetworkManager.post(toUrl: url, json: json) { (data, error) in
            guard error == nil else {
                self.handleFailedMbaasRequest(of: mbaasRequest)
                return
            }
            self.handleSuccessMbaasRequest(of: mbaasRequest)
        }
    }
    
    func unregister(didComplete: @escaping ResultBlockWithBool)
    {
        let mbaasRequest = MbaasRequestBuilder(operation: .unregistration).setUserInfo(visitorId: VisitorID!, customerId: CustomerID).build()
        let url = URL(string:  getMbaasPath(for: mbaasRequest))!
        guard let json = mbaasRequest.toMbaasJsonBody() else {
            OptiLogger.error("could not build Json object of \(mbaasRequest.operation)")
            return
        }
        NetworkManager.post(toUrl: url, json: json) { (data, error) in
            guard error == nil else {
               self.handleFailedMbaasRequest(of: mbaasRequest)
                didComplete(false)
                return
            }
            self.handleSuccessMbaasRequest(of: mbaasRequest)
            didComplete(true)
        }
    }
    
    func optIn()
    {
        let mbaasRequest = MbaasRequestBuilder(operation: .optIn)
            .setUserInfo(visitorId: VisitorID!, customerId: CustomerID)
            .build()
        let url = URL(string:  getMbaasPath(for: mbaasRequest))!
        guard let json = mbaasRequest.toMbaasJsonBody() else {
            OptiLogger.error("could not build Json object of \(mbaasRequest.operation)")
            return
        }

        NetworkManager.post(toUrl: url, json: json) { (data, error) in
            guard error == nil else {
                self.handleFailedMbaasRequest(of: mbaasRequest)
                return
            }
            UserInSession.shared.isMbaasOptIn = true
            self.handleSuccessMbaasRequest(of: mbaasRequest)
        }
    }
    
    func optOut()
    {
        let mbaasRequest = MbaasRequestBuilder(operation: .optOut)
            .setUserInfo(visitorId: VisitorID!, customerId: CustomerID)
            .build()
        let url = URL(string:  getMbaasPath(for: mbaasRequest))!
        guard let json = mbaasRequest.toMbaasJsonBody() else {
            OptiLogger.error("could not build Json object of \(mbaasRequest.operation)")
            return
        }
        NetworkManager.post(toUrl: url, json: json) { (data, error) in
            guard error == nil else {
                self.handleFailedMbaasRequest(of: mbaasRequest)
                return
            }
            self.handleSuccessMbaasRequest(of: mbaasRequest)
        }
    }
    private func handleFailedMbaasRequest(of mbaasRequest:MbaasRequestBody)
    {
        self.backupRequest(mbaasRequest)
        self.setSuccesFlag(succeed: false, for: mbaasRequest.operation)
    }
    
    private func handleSuccessMbaasRequest(of mbaasRequest:MbaasRequestBody)
    {
        self.clearBackupRequest(mbaasRequest)
        self.setSuccesFlag(succeed: true, for: mbaasRequest.operation)
    }
}
