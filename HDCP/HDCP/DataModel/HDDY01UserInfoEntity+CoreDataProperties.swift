//
//  HDDY01UserInfoEntity+CoreDataProperties.swift
//  HDCP
//
//  Created by 徐琰璋 on 16/4/7.
//  Copyright © 2016年 batonsoft. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension HDDY01UserInfoEntity {

    @NSManaged var avatar: String?
    @NSManaged var gender: NSNumber?
    @NSManaged var intro: String?
    @NSManaged var openUrl: String?
    @NSManaged var relation: NSNumber?
    @NSManaged var userId: NSNumber?
    @NSManaged var userName: String?
    @NSManaged var vip: NSNumber?
    @NSManaged var list: HDDY01ListEntity?

}
