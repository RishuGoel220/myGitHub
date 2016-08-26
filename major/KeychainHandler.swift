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
    

    
//-------------- Function to check if there exists a token -------------------------
    func hasAuthToken()->Bool{
        let keychain = Keychain(service: "com.example.Practo.major")
        let AUTH_TOKEN = keychain["Auth_token"]
        if AUTH_TOKEN == nil || AUTH_TOKEN==""{
            return false
        }
        else{
            return true
        }
    }
    
//----------------------- Function to get the token ---------------------------------
    func getAuthToken()-> String {
        let keychain = Keychain(service: "com.example.Practo.major")
        return (keychain["Auth_token"]! as String)
    }
    
//----------------------- Function to remove the token ------------------------------
    func removeAuthToken(){
        let keychain = Keychain(service: "com.example.Practo.major")
        do {
            try keychain.remove("Auth_token")
        } catch let error {
            print("error: \(error)")
        }
    }
}
