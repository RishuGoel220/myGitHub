//
//  dataHandler.swift
//  major
//
//  Created by Rishu Goel on 26/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import Foundation
import SwiftyJSON

class dataHandler{
    
    func getContributors(repositoryName: String, completion: (result: Bool)-> Void){
        APIcaller().getContributorsCall(repositoryName){
            response in
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
    //////////////////
    
    
    
    func getContributorStats(repositoryName: String, username: String, completion: (responseBool: Bool) -> Void){
        APIcaller().getContributorStatsCall(repositoryName, username: username){
            response in
            if (response.response?.statusCode == 202){
                self.getContributorStats(repositoryName,username: username){
                    responseBool in
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
    /////////////////
    
    func getRepositories(completion: (result:Bool)-> Void){
        APIcaller().getRepositoriesCall(){
            response in
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
    
    
    //////////////////////////////////
    func getPRCount(repositoryName : String, username : String, completion: (result:Bool)-> Void){
        
        var openPRCount : Int = 0
        var mergedPRCount : Int = 0
        APIcaller().getPRCountCall(repositoryName, username: username){
            response in
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
                DatabaseHandler().addPRCount(repositoryName,username: username, PR: [openPRCount,mergedPRCount])
                completion(result: true)
            case let .Failure(errorvalue):
                print(errorvalue)
            }
            
        }
        
    }
    
    
    ///////////////////////////////////
    func getIssueCount(repositoryName : String, username : String, completion: (result:Bool)-> Void) {
        var openIssueCount : Int = 0
        var closedIssueCount : Int = 0
        APIcaller().getIssueCountCall(repositoryName, username: username){
            response in
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
                DatabaseHandler().addIssueCount(repositoryName,username: username, Issues: [openIssueCount,closedIssueCount])
                completion(result: true)
            case let .Failure(errorvalue):
                print(errorvalue)
                completion(result: false)
            }
        }
    }
    ////////////////////////////////////
    func getCommitCount(repositoryName : String, username : String, completion: (result:Bool)-> Void){
        
        var commitCount : Int = 0
        APIcaller().getCommitCountCall(repositoryName, username: username){
            response in
            
            switch response.result {
            case let .Success(successvalue):
                let json = JSON(successvalue)
                
                for item in json.arrayValue {
                    commitCount = commitCount + item["total"].intValue
                }
                completion(result: false)
            case let .Failure(errorvalue):
                print(errorvalue)
            }
            
        }
    }
    
    
    
}