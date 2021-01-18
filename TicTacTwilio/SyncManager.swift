//
//  SyncManager.swift
//  TicTacTwilio
//
//  Copyright (c) 2017 Twilio, Inc. All rights reserved.
//

import UIKit
import TwilioSyncClient

class SyncManager: NSObject {
    static let sharedManager = SyncManager()
    fileprivate override init() {}
    
    var syncClient : TwilioSyncClient?
    
    func login(completion: @escaping (_ syncClient: TwilioSyncClient?) -> Void) {
        if self.syncClient != nil {
            logout()
        }

        let token = generateToken()
        let properties = TwilioSyncClientProperties()
        if let token = token {
            TwilioSyncClient.syncClient(withToken: token, properties: properties, delegate: self, completion: { (result, syncClient) in
                if !result.isSuccessful {
                    print("TTT: error creating client: \(String(describing: result.error))")
                    completion(nil)
                } else {
                    self.syncClient = syncClient
                    completion(syncClient)
                }
            })
        }
    }
    
    func logout() {
        if let syncClient = syncClient {
            syncClient.shutdown()
            self.syncClient = nil
        }
    }
    
    fileprivate func generateToken() -> String? {
        let urlString = "http://localhost:4567/token"
        
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
