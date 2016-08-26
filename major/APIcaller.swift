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
import CoreData

class APIcaller{
    
    
    let API_URL = "https://api.github.com/"
    let CLIENT_SECRET = "c0ea6710c59e4c4a26d7b875f34eab2c66f27e52"
    let CLIENT_ID = "85a3f37ae5540cdc80f2"
    
    
// MARK: API functions for Contributor Data
//-------------------------------- API call for fetching contributors and putting it in database -----------------------------
    func getContributorsCall(repositoryName: String, completion: (response: (Response<AnyObject,NSError>))-> Void){
        
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        
        Alamofire.request(.GET, "https://api.github.com/repos/\(DatabaseHandler().currentUser().valueForKey("username") as! String)/"+repositoryName+"/contributors", parameters: [:], headers: headers)
            .responseJSON { response in
                completion(response: response)
                
        }
    }
    

    
    
    
//-------------------------------- API call for fetching the extra contributor Details -----------------------------
    func getContributorStatsCall(repositoryName: String, username: String, completion: (response: (Response<AnyObject,NSError>)) -> Void){
        
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        
        Alamofire.request(.GET, "https://api.github.com/repos/\(username)/\(repositoryName)/stats/contributors", parameters: [:],headers: headers)
            .responseJSON { response in
                completion(response: response)
        }

        
    }
    
// MARK: Repository Details API functions

    
//-------------------------------- API call for fetching repository and putting it in database -----------------------------
    func getRepositoriesCall(completion: (response: (Response<AnyObject,NSError>))-> Void){
        
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        
        Alamofire.request(.GET, "https://api.github.com/users/\(DatabaseHandler().currentUser().valueForKey("username") as! String)/repos", parameters: [:], headers: headers)
            .responseJSON { response in
                
                completion(response: response)
        }
    }
    
//--------------------- API call to get Issues count of repository -------------------
    
    func getIssueCountCall(repositoryName : String, username : String, completion: (response: (Response<AnyObject,NSError>))-> Void) {
        let keychain = Keychain(service: "com.example.Practo.major")
        let headers = ["Authorization": "bearer \(keychain["Auth_token"]! as String)"]
        Alamofire.request(.GET, "https://api.github.com/repos/\(username)/\(repositoryName)/issues", parameters: [:],headers: headers)
            .responseJSON { response in
                completion(response: response)
                                
        }
    }
    
    
//--------------------- API call to get Pull request count of repository -------------------
    func getPRCountCall(repositoryName : String, username : String, completion: (response: (Response<AnyObject,NSError>))-> Void){
        
        let keychain = Keychain(service: "com.example.Practo.major")
        let headers = ["Authorization": "token \(keychain["Auth_token"]! as String)"]
        Alamofire.request(.GET, "https://api.github.com/repos/\(username)/\(repositoryName)/issues", parameters: [:], headers: headers)
            .responseJSON { response in
                completion(response: response)
                
        }
        
    }
    
//--------------------- API call to get commit count of repository ---------------------------
    func getCommitCountCall(repositoryName : String, username : String, completion: (response: (Response<AnyObject,NSError>))-> Void){
        
        
        let keychain = Keychain(service: "com.example.Practo.major")
        let headers = ["Authorization": "token \(keychain["Auth_token"]! as String) "]
        Alamofire.request(.GET, "https://api.github.com/repos/\(username)/\(repositoryName)/issues", parameters: [:], headers: headers)
            .responseJSON { response in
                completion(response: response)
        }
        
    }

    
// MARK: API Login  Functions
//--------------------- API Call for Login using header-------------------------------------------
    func login(userName : String, password : String, otp: String, completion : (Response<AnyObject, NSError> ) -> ()){
        let parameters = [
            "scopes"    : ["public_repo", "repo", "read:org", "repo:status"],
            "note" : "token for repos",
            "client_id" : CLIENT_ID,
            "client_secret" : CLIENT_SECRET
        ]
        
        Alamofire.request(.POST, API_URL+"authorizations", parameters: parameters as? [String : AnyObject], encoding: .JSON, headers:headerReturn(userName, password: password, otp: otp) ).responseJSON { response in
                switch response.result {
                case let .Success(successvalue):
                    if response.response?.statusCode <= 201 {
                        let jsonData = JSON(data: response.data!)
                        let keychain = Keychain(service: "com.example.Practo.major")
                        do {
                            try keychain.set(jsonData["token"].stringValue,key : "Auth_token")
                        }catch let error {
                            print(error)
                        }
                    }
                case let .Failure(errorvalue):
                    print(errorvalue)
                }
                completion(response)
            }
    }
    
//------------------------ Provide header based on data based for login -------------------------------------------
    func headerReturn(userName : String, password : String, otp :String)-> [String:String]{
        let credentialData = "\(userName):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        if !(otp == ""){
            
            return ["Authorization": "Basic \(base64Credentials)", "X-GitHub-OTP": "\(otp)"]
        }
        else{
            return ["Authorization": "Basic \(base64Credentials)"]
        }
    }
    
    
}