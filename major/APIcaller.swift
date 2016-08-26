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
    func getContributors(repositoryName: String, completion: (result:Bool)-> Void){
        
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        
        Alamofire.request(.GET, "https://api.github.com/repos/\(DatabaseHandler().currentUser().valueForKey("username") as! String)/"+repositoryName+"/contributors", parameters: [:], headers: headers)
            .responseJSON { response in
                
                
                switch response.result {
                case let .Success(successvalue):
                    
                    let json = JSON(successvalue)
                    for item in json.arrayValue {
                        
                        let contributorName = item["login"].stringValue
                        let contributions = item["contributions"].stringValue
                        let avatarUrl = item["avatar_url"].stringValue
                        
                        let contributors = DatabaseHandler().fetchContributorByName(contributorName, repositoryName: repositoryName)
                        
                        if contributors.count != 0{
                            DatabaseHandler().updateExistingContributor(contributorName, repositoryName: repositoryName, Url: avatarUrl,contributions: contributions)
                            continue
                        }
                        else{
                            DatabaseHandler().AddNewContributor(contributorName, repositoryName: repositoryName, contributions: contributions, Url: avatarUrl)
                        }
                    }
                    completion(result: true)
                case let .Failure(errorvalue):
                    print(errorvalue)
                    completion(result: false)
                    
                }
        }
    }
    

    
    
    
//-------------------------------- API call for fetching the extra contributor Details -----------------------------
    func getContributorStats(repositoryName: String, username: String, completion: (responseBool: Bool) -> Void){
        
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        
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
                            
                        }
                        DatabaseHandler().addContributorStats(repositoryName, contributorName: contributorName, linesAdded : linesAdded, linesDeleted: linesDeleted, commits: commits)
                        
                    }
                   completion(responseBool: true)
                }
                else{
                    completion(responseBool: false)
                }
        }

        
    }
    
// MARK: Repository Details API functions

    
//-------------------------------- API call for fetching repository and putting it in database -----------------------------
    func getRepositories(completion: (result:Bool)-> Void){
        
        let headers = ["Authorization": "bearer \(KeychainHandler().getAuthToken())"]
        
        Alamofire.request(.GET, "https://api.github.com/users/\(DatabaseHandler().currentUser().valueForKey("username") as! String)/repos", parameters: [:], headers: headers)
            .responseJSON { response in
                
                
                switch response.result {
                case let .Success(successvalue):
                    
                    let json = JSON(successvalue)
                    for item in json.arrayValue {
                        
                        let repositoryName = item["name"].stringValue
                        let descriptionRepo = item["description"].stringValue
                        let avatarUrl =  item["owner"]["avatar_url"].stringValue
                        let repositories = DatabaseHandler().fetchRepositoryByName(repositoryName)
                        
                        if repositories.count != 0{
                            DatabaseHandler().updateExistingRepository(repositoryName, Url: avatarUrl, description: descriptionRepo)
                            continue
                        }
                        else{
                            DatabaseHandler().AddNewRepository(repositoryName, isFavourite: "false", description: descriptionRepo, Url: avatarUrl)
                        }
                    }
                    completion(result: true)
                case let .Failure(errorvalue):
                    completion(result: false)
                    print(errorvalue)
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
    
// MARK: API Login  Functions
//------------------------ API Call for Login using header -------------------------------------------
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