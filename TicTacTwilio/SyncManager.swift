//
//  SyncManager.swift
//  TicTacTwilio
//
//  Copyright © 2011-2016 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioSyncClient

class SyncManager: NSObject {
    static let sharedManager = SyncManager()
    fileprivate override init() {}
    
    var syncClient : TwilioSyncClient?
    
    func login() {
        if self.syncClient != nil {
            logout()
        }

        let token = generateToken()
        let properties = TwilioSyncClientProperties()
        if let token = token {
            self.syncClient = TwilioSyncClient(token: token,
                                          properties: properties,
                                          delegate: self)
        }
    }
    
    func logout() {
        if let syncClient = syncClient {
            syncClient.shutdown()
            self.syncClient = nil
        }
    }
    
    fileprivate func generateToken() -> String? {
        let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString
        let urlString = "http://localhost:4567/token?device=\(identifierForVendor!)"
        
        var token : String?
        do {
            if let url = URL(string: urlString),
                let data = try? Data(contentsOf: url),
                let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                token = result["token"] as? String
            }
        } catch {
            print("Error obtaining token: \(error)")
        }
        
        return token
    }
}

extension SyncManager : TwilioSyncClientDelegate {
    
}
