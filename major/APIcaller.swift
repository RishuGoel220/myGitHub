//
//  LoginActivityHandler.swift
//  major
//
//  Created by Rishu Goel on 18/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainAccess

class APIcaller{
    
    
    let API_URL = "https://api.github.com/"
    let CLIENT_SECRET = "c0ea6710c59e4c4a26d7b875f34eab2c66f27e52"
    let CLIENT_ID = "85a3f37ae5540cdc80f2"
    var AUTH_TOKEN :String = ""
    
    
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
    
    
    
    
    
    
    
    func login(userName : String, password : String, otp: String, completion : (JSON, Response<AnyObject, NSError> ) -> ()){
        let parameters = [
            "scopes"    : ["repo"],
            "note" : "token for repos",
            "client_id" : CLIENT_ID,
            "client_secret" : CLIENT_SECRET
        ]
        
        
        let credentialData = "\(userName):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        if !(otp == ""){
            
            let headers = ["Authorization": "Basic \(base64Credentials)", "X-GitHub-OTP": "\(otp)"]
            Alamofire.request(.POST, API_URL+"authorizations", parameters: parameters as? [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                let jsonData = JSON(data: response.data!)
                print(response.response)
                if (response.result.error == nil){
                    
                    let AUTH_TOKEN = jsonData["token"].stringValue
                    
                    if response.response?.statusCode <= 300 {
                        let keychain = Keychain(service: "com.example.Practo.major")
                        do {
                            try keychain.set(AUTH_TOKEN,key : "Auth_token")
                        }catch let error {
                            print(error)
                        }
                    }
                    
                    completion(jsonData, response)
                }
                else{
                    completion(jsonData, response)
                }
                
            }
        }
        else{
            
            let headers = ["Authorization": "Basic \(base64Credentials)"]
            Alamofire.request(.POST, API_URL+"authorizations", parameters: parameters as? [String : AnyObject], encoding: .JSON, headers: headers).responseJSON { response in
                let jsonData = JSON(data: response.data!)
                print(response.response)
                if (response.result.error == nil){
                    
                    let AUTH_TOKEN = jsonData["token"].stringValue
                    
                    if response.response?.statusCode <= 300 {
                        let keychain = Keychain(service: "com.example.Practo.major")
                        do {
                            try keychain.set(AUTH_TOKEN,key : "Auth_token")
                        }catch let error {
                            print(error)
                        }
                    }
                    
                    completion(jsonData, response)
                }
                else{
                    completion(jsonData, response)
                }
                
            }
        }
        
        
    }
    
    
    
}