//
//  HDCT08Model.swift
//  HDCP
//
//  Created by 徐琰璋 on 16/3/15.
//  Copyright © 2016年 batonsoft. All rights reserved.
//

import Foundation
import ObjectMapper

class HDCT08Response:Mappable {
    
    var request_id:String?
    var result:HDCT08Result?
    
    required init?(_ map: Map){
        mapping(map)
    }
    func mapping(map: Map) {
        
        request_id <- map["request_id"]
        result <- map["result"]
        
    }

}

class HDCT08Result: Mappable {
    
    var list:Array<HDCT08ListModel>?
    
    required init?(_ map: Map){
        mapping(map)
    }
    
    func mapping(map: Map) {
        
        list <- map["list"]
        
    }
    
}

class HDCT08FavoriteModel:Mappable {
    
    
    var id:Int!
    var name:String!
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        
        id <- map["Id"]
        name <- map["Name"]
        
    }
    
}

class HDCT08CommonInfoModel:Mappable {
    
    var commonId:Int?
    var desc:String?
    var img:String?
    var tagId:Int?
    var hasVideo:Int?
    var tagName:String?
    var tagUrl:String?
    var title:String?
    var url:String?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        
        commonId <- map["CommonId"]
        desc <- map["Desc"]
        img <- map["Img"]
        hasVideo <- map["HasVideo"]
        url <- map["Url"]
        tagName <- map["TagName"]
        tagUrl <- map["TagUrl"]
        title <- map["Title"]
        url <- map["Url"]
        
    }
    
}

class HDCT08ListModel:Mappable {
    
    var address:String!
    var avatar:String!
    var gender:Int!
    var intro:String!
    var listUrl:String!
    var openUrl:String!
    var relation:Int!
    var sameFeature:String!
    var styleType:Int!
    var userId:Int!
    var userName:String!
    var vip:Int!
    var entityType:Int!
    var favoriteList:Array<HDCT08FavoriteModel>?
    var commonInfo:HDCT08CommonInfoModel?
    
    required init?(_ map: Map) {
        mapping(map)
    }
    
    func mapping(map: Map) {
        
        address <- map["Address"]
        avatar <- map["Avatar"]
        gender <- map["Gender"]
        intro <- map["Intro"]
        listUrl <- map["ListUrl"]
        openUrl <- map["OpenUrl"]
        relation <- map["Relation"]
        sameFeature <- map["SameFeature"]
        styleType <- map["StyleType"]
        userId <- map["UserId"]
        userName <- map["UserName"]
        vip <- map["Vip"]
        entityType <- map["entityType"]
        favoriteList <- map["FavoriteList"]
        commonInfo <- map["CommonInfo"]
        
    }
    
}