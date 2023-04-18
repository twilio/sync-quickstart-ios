//
//  SyncManager.swift
//  TicTacTwilio
//
//  Copyright (c) 2017 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioSyncClient

enum SyncManagerError: Error {

    case clientInitFailed(Error)
    case cannotGetToken
    case wrongUrl
}

class SyncManager: NSObject {

    static let sharedManager = SyncManager()
    private override init() {}
    
    var syncClient : TwilioSyncClient?
    
    func login() async throws -> TwilioSyncClient {
        // log out from the previous session first
        if self.syncClient != nil {
            logout()
        }

        // TODO: return client currently awaiting for if any

        let token = try await generateToken()
        let properties = TwilioSyncClientProperties()

        let (result, client) = await TwilioSyncClient.syncClient(withToken: token, properties: properties, delegate: self)

        guard result.isSuccessful else {
            throw SyncManagerError.clientInitFailed(result.error!)
        }

        syncClient = client

        return client!
    }
    
    func logout() {
        if let syncClient = syncClient {
            syncClient.shutdown()
            self.syncClient = nil
        }
    }
    
    private func generateToken() async throws -> String {
        let urlString = "http://localhost:4567/token"
        
        guard let url = URL(string: urlString) else {
            throw SyncManagerError.wrongUrl
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let urlResponse = response as? HTTPURLResponse,
              urlResponse.statusCode / 100 == 2,
              let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
              let token = result["token"] as? String else {
//              let token = String(data: data, encoding: .utf8) else {
            print("Failed to get token with response \(response)")
            throw SyncManagerError.cannotGetToken
        }

        return token
    }
}

extension SyncManager : TwilioSyncClientDelegate {
    
}
