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


//------------------------------------------------------------------------------
// DESCRIPTION: Class to make API calls and return the response
//------------------------------------------------------------------------------
class APIcaller{
    
    
    let API_URL = "https://api.github.com/"
    
    
    
// MARK: API functions for Contributor Data
    
//------------------------------------------------------------------------------
// DESCRIPTION: API call for fetching contributors
//              Returns the response of API call
//------------------------------------------------------------------------------
    func getContributorsCall(repositoryName: String,
                             completion: (response: (Response<AnyObject,NSError>))-> Void){
     // get auth token for authorization header
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        let username = DatabaseHandler().currentUser().valueForKey("username") as! String
        let url = "https://api.github.com/repos/"+username+"/"+repositoryName+"/contributors"
    // make API call using URL and header for authorization
        Alamofire.request(.GET, url, parameters: [:], headers: headers)
            .responseJSON { response in
                completion(response: response)
                
        }
    }
    

//------------------------------------------------------------------------------
// DESCRIPTION: API call for fetching extra contributors details
//              Returns the response of API call
//------------------------------------------------------------------------------
    func getContributorStatsCall(repositoryName: String, username: String,
                                 completion: (response: (Response<AnyObject,NSError>)) -> Void){
       // get auth token for authorization header
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        let url = "https://api.github.com/repos/\(username)/\(repositoryName)/stats/contributors"
        
        Alamofire.request(.GET, url, parameters: [:],headers: headers)
            .responseJSON { response in
                completion(response: response)
        }
    }
    
// MARK: Repository Details API functions

//------------------------------------------------------------------------------
// DESCRIPTION: API call for fetching Repositories for currently active user
//              Returns the response of API call
//------------------------------------------------------------------------------
    func getRepositoriesCall(completion: (response: (Response<AnyObject,NSError>))-> Void){
        
    // get auth token for authorization header
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        let username = DatabaseHandler().currentUser().valueForKey("username") as! String
        let url = "https://api.github.com/users/\(username)/repos"
        Alamofire.request(.GET, url, parameters: [:], headers: headers)
            .responseJSON { response in
                
                completion(response: response)
        }
    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: API call for fetching Issues in repository
//              Returns the response of API call
//------------------------------------------------------------------------------
    func getIssueCountCall(repositoryName : String, username : String,
                           completion: (response: (Response<AnyObject,NSError>))-> Void) {
        
        // get auth token for authorization header
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        let url = "https://api.github.com/repos/\(username)/\(repositoryName)/issues"
        Alamofire.request(.GET, url, parameters: [:],headers: headers)
            .responseJSON { response in
                completion(response: response)
                                
        }
    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: API call for fetching Pull requests in repository
//              Returns the response of API call
//------------------------------------------------------------------------------
    func getPRCountCall(repositoryName : String, username : String,
                        completion: (response: (Response<AnyObject,NSError>))-> Void){
        
        // get auth token for authorization header
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        let url = "https://api.github.com/repos/\(username)/\(repositoryName)/pulls"
        Alamofire.request(.GET, url, parameters: [:], headers: headers)
            .responseJSON { response in
                completion(response: response)
                
        }
        
    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: API call for fetching commits in repository
//              Returns the response of API call
//------------------------------------------------------------------------------
    func getCommitCountCall(repositoryName : String, username : String, completion: (response: (Response<AnyObject,NSError>))-> Void){
        
        // get auth token for authorization header
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        let url = "https://api.github.com/repos/\(username)/\(repositoryName)/commits"
        Alamofire.request(.GET, url, parameters: [:], headers: headers)
            .responseJSON { response in
                completion(response: response)
        }
        
    }

    
// MARK: API Login  Functions
    
//------------------------------------------------------------------------------
// DESCRIPTION: API call for login to Github Account
//              Returns the response of API call
//------------------------------------------------------------------------------
    func login(userName : String, password : String, otp: String, completion : (Response<AnyObject, NSError> ) -> ()){
        let parameters = [
            "scopes"    : ["public_repo", "repo", "read:org", "repo:status"],
            "note" : "token for repos",
            "client_id" : UtilityHandler().valueForAPI(named: "CLIENT_ID"),
            "client_secret" : UtilityHandler().valueForAPI(named: "CLIENT_SECRET")
        ]
        
        Alamofire.request(.POST, API_URL+"authorizations",
            parameters: parameters as? [String : AnyObject], encoding: .JSON,
            headers:headerReturn(userName, password: password, otp: otp) ).responseJSON
            { response in
                switch response.result {
                case let .Success(successvalue):
                // if response is valid enter the auth token in keychain
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
    
//------------------------------------------------------------------------------
// DESCRIPTION: returns header based on the otp text field
//              if empty gives basic auth header else OTP header for 2 factor Auth
//------------------------------------------------------------------------------
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