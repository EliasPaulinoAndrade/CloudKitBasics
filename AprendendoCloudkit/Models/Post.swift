//
//  Post.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 25/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import CloudKit

struct Post: CloudObject {
    
    var recordID: CKRecord.ID?
    var title: String?
    var content: String?
    var date: Date?
    var author: CKRecord.Reference?
    
    init() {
        
    }
    
    init(ckRecord: CKRecord) {
        
        self.title = ckRecord["title"]
        self.content = ckRecord["content"]
        self.date = ckRecord["date"]
        self.author = ckRecord["author"]
        self.recordID = ckRecord.recordID
    }
    
    init(withTitle title: String, content: String, date: Date, andAuthor author: CKRecord.Reference) {
        self.title = title
        self.content = content
        self.date = date
        self.author = author
    }
}
