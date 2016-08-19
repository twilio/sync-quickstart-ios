//
//  SyncManager.swift
//  TicTacTwilio
//
//  Copyright © 2011-2016 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioCommon
import TwilioSyncClient

class SyncManager: NSObject {
    static let sharedManager = SyncManager()
    private override init() {}
    
    private var accessManager : TwilioAccessManager?
    var syncClient : TwilioSyncClient?
    
    func login() {
        if self.syncClient != nil {
            logout()
        }

        let token = generateToken()
        self.accessManager = TwilioAccessManager(token: token, delegate: self)
        let properties = TwilioSyncClientProperties()
        self.syncClient = TwilioSyncClient(accessManager: accessManager,
                                      properties: properties,
                                      delegate: self)
    }
    
    func logout() {
        if let syncClient = syncClient {
            syncClient.shutdown()
            self.syncClient = nil
        }
        self.accessManager = nil
    }
    
    private func generateToken() -> String? {
        let identifierForVendor = UIDevice.currentDevice().identifierForVendor?.UUIDString
        let urlString = "http://localhost:4567/token?device=\(identifierForVendor!)"
        
        var token : String?
        do {
            if let url = NSURL(string: urlString),
                data = NSData(contentsOfURL: url),
                result = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] {
                token = result["token"] as? String
            }
        } catch {
            print("Error obtaining token: \(error)")
        }
        
        return token
    }
}

extension SyncManager : TwilioAccessManagerDelegate {
    func accessManagerTokenExpired(accessManager: TwilioAccessManager!) {
        let token = generateToken()
        accessManager.updateToken(token)
    }
    
    func accessManager(accessManager: TwilioAccessManager!, error: NSError!) {
        print("Error updating token: \(error)")
    }
}

extension SyncManager : TwilioSyncClientDelegate {
    
}