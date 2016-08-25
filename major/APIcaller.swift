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
    
    
    func getContributorStats(repositoryName: String, username: String, completion: (responseBool: Bool) -> Void){
        
        let keychain = Keychain(service: "com.example.Practo.major")
        let headers = ["Authorization": "bearer \(keychain["Auth_token"]! as String)"]
        Alamofire.request(.GET, "https://api.github.com/repos/\(username)/\(repositoryName)/stats/contributors", parameters: [:],headers: headers)
            .responseJSON { response in
                if (response.response?.statusCode == 202){
                    self.getContributorStats(repositoryName,username: username){
                        (responseBool: Bool) -> Void in
                        if responseBool == true{
                            completion(responseBool: true)
                        }
                        else{
                        completion(responseBool: false)
                        }
                    }
                    
                }
                else if (response.response?.statusCode == 200){
                    let json = JSON(response.result.value!)
                    for item in json.arrayValue{
                        let contributorName = item["author"]["login"].stringValue
                        let commits = item["total"].intValue
                        var linesAdded = 0
                        var linesDeleted = 0
                        for week in item["weeks"].arrayValue {
                            linesAdded = linesAdded + week["a"].intValue
                            linesDeleted = linesDeleted + week["d"].intValue
                            DatabaseHandler().addContributorStats(repositoryName, contributorName: contributorName, linesAdded : linesAdded, linesDeleted: linesDeleted, commits: commits)
                            
                        }
                        
                    }
                   completion(responseBool: true)
                }
                else{
                    completion(responseBool: false)
                }
        }

        
    }
    
    
//--------------------- API call to get Issues count of repository -------------------
    
    func getIssueCount(repositoryName : String, username : String, result: (Issues: [Int])-> Void) {
        var openIssueCount : Int = 0
        var closedIssueCount : Int = 0
        let keychain = Keychain(service: "com.example.Practo.major")
        let headers = ["Authorization": "bearer \(keychain["Auth_token"]! as String)"]
        Alamofire.request(.GET, "https://api.github.com/repos/\(username)/\(repositoryName)/issues", parameters: [:],headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case let .Success(successvalue):
                    let json = JSON(successvalue)
                    
                    for item in json.arrayValue {
                        if item["state"] == "open"{
                            openIssueCount = openIssueCount + 1
                        }
                        else{
                            closedIssueCount = closedIssueCount + 1
                        }
                        
                        
                    }
                    result(Issues: [openIssueCount, closedIssueCount])
                case let .Failure(errorvalue):
                    print(errorvalue)
                }
                
        }
    }
    
    
//--------------------- API call to get Pull request count of repository -------------------
    func getPRCount(repositoryName : String, username : String, result: (PR: [Int])->Void){
        
        var openPRCount : Int = 0
        var mergedPRCount : Int = 0
        let keychain = Keychain(service: "com.example.Practo.major")
        let headers = ["Authorization": "token \(keychain["Auth_token"]! as String)"]
        Alamofire.request(.GET, "https://api.github.com/repos/\(username)/\(repositoryName)/issues", parameters: [:], headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case let .Success(successvalue):
                    let json = JSON(successvalue)
                    
                    for item in json.arrayValue {
                        if item["state"] == "open"{
                            openPRCount = openPRCount + 1
                        }
                        else{
                            mergedPRCount = mergedPRCount + 1
                        }
                        
                        
                    }
                    result(PR: [openPRCount, mergedPRCount])
                case let .Failure(errorvalue):
                    print(errorvalue)
                }
                
        }
        
    }
    
//--------------------- API call to get commit count of repository ---------------------------
    func getCommitCount(repositoryName : String, username : String, commitcount: (Int)->Void){
        var commitCount : Int = 0
        
        let keychain = Keychain(service: "com.example.Practo.major")
        let headers = ["Authorization": "token \(keychain["Auth_token"]! as String) "]
        Alamofire.request(.GET, "https://api.github.com/repos/\(username)/\(repositoryName)/issues", parameters: [:], headers: headers)
            .responseJSON { response in
                
                switch response.result {
                case let .Success(successvalue):
                    let json = JSON(successvalue)
                    
                    for item in json.arrayValue {
                        commitCount = commitCount + item["total"].intValue
                    }
                    commitcount(commitCount)
                case let .Failure(errorvalue):
                    print(errorvalue)
                }
                
        }
        
    }
    
    
    
    func login(userName : String, password : String, otp: String, completion : (JSON, Response<AnyObject, NSError> ) -> ()){
        let parameters = [
            "scopes"    : ["public_repo", "repo", "read:org", "repo:status"],
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
                
                if (response.result.error == nil){
                    
                    let AUTH_TOKEN = jsonData["token"].stringValue
                    
                    
                    if response.response?.statusCode <= 201 {
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
                
                if (response.result.error == nil){
                   
                    let AUTH_TOKEN = jsonData["token"].stringValue
                    
                    if response.response?.statusCode <= 201{
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