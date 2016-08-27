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


//----------------------------------------------------------------------------------
// Description: Class to Access the supoort keychain functions
//----------------------------------------------------------------------------------
public class KeychainHandler{
    

    
//-------------- Function to check if there exists a token -------------------------
// Description: If auth token exists returns true otherwise false
//----------------------------------------------------------------------------------
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
// Description: Return the auth token as String
//----------------------------------------------------------------------------------
    func getAuthToken()-> String {
        let keychain = Keychain(service: "com.example.Practo.major")
        // send the auth token as string
        return (keychain["Auth_token"]! as String)
    }
    
//----------------------- Function to remove the token ------------------------------
// Description: Deletes the auth key from keychain
//----------------------------------------------------------------------------------
    func removeAuthToken(){
        let keychain = Keychain(service: "com.example.Practo.major")
        do {
            // remove the auth token
            try keychain.remove("Auth_token")
        } catch let error {
            print("error: \(error)")
        }
    }
}
