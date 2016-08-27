//
//  dataHandler.swift
//  major
//
//  Created by Rishu Goel on 26/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import Foundation
import SwiftyJSON

//------------------------------------------------------------------------------
// DESCRIPTION: Class to handle all the data activities. It is asks api for data
//              using APIcaller functions and stores the data in database by
//              using databaseHandler functions
//------------------------------------------------------------------------------
class dataHandler{
    
    
//------------------------------------------------------------------------------
// DESCRIPTION: Get contributors Basic details for a given repository
//------------------------------------------------------------------------------
    func getContributors(repositoryName: String, completion: (result: Bool)-> Void){
        // calls the api for contributor
        APIcaller().getContributorsCall(repositoryName){
            response in
            switch response.result {
            // if its a success parse the json
            case let .Success(successvalue):
                let json = JSON(successvalue)
                for item in json.arrayValue {
                    
                    let contributorName = item["login"].stringValue
                    let contributions = item["contributions"].stringValue
                    let avatarUrl = item["avatar_url"].stringValue
                    // check if a contributor by the name exists
                    let contributors = DatabaseHandler().fetchContributorByName(contributorName,
                                                                                repositoryName: repositoryName)
                    // if it exists update the contributor database
                    if contributors.count != 0{
                        DatabaseHandler().updateExistingContributor(contributorName,
                                                                    repositoryName: repositoryName, Url: avatarUrl,contributions: contributions)
                    }
                    // if it doesnt exist add new contributor
                    else{
                        DatabaseHandler().AddNewContributor(contributorName,
                                                            repositoryName: repositoryName, contributions: contributions, Url: avatarUrl)
                    }
                }
                // sent completion result true when data is properly fetched
                completion(result: true)
            case let .Failure(errorvalue):
                print(errorvalue)
                completion(result: false)
            }
        }
    }
    
    
//------------------------------------------------------------------------------
// DESCRIPTION: Get contributors Extra details for a given repository
//------------------------------------------------------------------------------
    func getContributorStats(repositoryName: String, username: String,
                             completion: (responseBool: Bool) -> Void){
        // call the api for extra details
        APIcaller().getContributorStatsCall(repositoryName, username: username){
            response in
            // if response in 202 ask again as it caches on data on first request
            if (response.response?.statusCode == 202){
                self.getContributorStats(repositoryName,username: username){
                    responseBool in
                    if responseBool == true{
                        // if the second call returns true return true
                        completion(responseBool: true)
                    }
                        // else false for fetching
                    else{
                        completion(responseBool: false)
                    }
                }
                
            }
                // 200 is the code parse the data and add update to database
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
                    DatabaseHandler().addContributorStats(repositoryName,
                    contributorName: contributorName, linesAdded : linesAdded,
                    linesDeleted: linesDeleted, commits: commits)
                    
                }
                // return true when data is fetched and written
                completion(responseBool: true)
            }
            else{
                completion(responseBool: false)
            }

        }
    
    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: Get Repositories
//------------------------------------------------------------------------------
    func getRepositories(completion: (result:Bool)-> Void){
        // call the api for repositories
        APIcaller().getRepositoriesCall(){
            response in
            switch response.result {
            // if the reponse has success parse the data and feed it to database
            case let .Success(successvalue):
                
                let json = JSON(successvalue)
                for item in json.arrayValue {
                    
                    let repositoryName = item["name"].stringValue
                    let descriptionRepo = item["description"].stringValue
                    let avatarUrl =  item["owner"]["avatar_url"].stringValue
                    let repositories = DatabaseHandler().fetchRepositoryByName(repositoryName)
                    // if there is a repository by that name
                    if repositories.count != 0{
                        DatabaseHandler().updateExistingRepository(repositoryName,
                            Url: avatarUrl, description: descriptionRepo)
                        continue
                    }
                    // otherwise add a new repository to dattabasse
                    else{
                        DatabaseHandler().AddNewRepository(repositoryName,
                            isFavourite: "false", description: descriptionRepo, Url: avatarUrl)
                    }
                }
                completion(result: true)
            case let .Failure(errorvalue):
                completion(result: false)
                print(errorvalue)
            }
        }
    }
    
    
//------------------------------------------------------------------------------
// DESCRIPTION: Get PR count for a given repository
//------------------------------------------------------------------------------
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
                DatabaseHandler().addPRCount(repositoryName,
                                             username: username, PR: [openPRCount,mergedPRCount])
                completion(result: true)
            case let .Failure(errorvalue):
                print(errorvalue)
            }
            
        }
        
    }
    
//------------------------------------------------------------------------------
// DESCRIPTION: Get Issue count for a given repository
//------------------------------------------------------------------------------
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

//------------------------------------------------------------------------------
// DESCRIPTION: Get Commit Count for a given repository
//------------------------------------------------------------------------------
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