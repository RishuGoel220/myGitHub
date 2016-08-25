//
//  KeychainHandler.swift
//  major
//
//  Created by Rishu Goel on 24/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import Foundation
import SystemConfiguration
import KeychainAccess

public class KeychainHandler{
    
    
    func hasAuthToken()->Bool{
        
        
        let keychain = Keychain(service: "com.example.Practo.major")
        let AUTH_TOKEN = keychain["Auth_token"]
        
        debugPrint(AUTH_TOKEN)
        if AUTH_TOKEN == nil || AUTH_TOKEN==""{
            return false
        }
        else{
            return true
        }
    }
    
    func removeAuthToken(){
        let keychain = Keychain(service: "com.example.Practo.major")
        do {
            try keychain.remove("Auth_token")
        } catch let error {
            print("error: \(error)")
        }
    }
}
