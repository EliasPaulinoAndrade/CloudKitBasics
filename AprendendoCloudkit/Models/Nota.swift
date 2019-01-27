//
//  Nota.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import CloudKit

struct Nota: CloudObject {
    
    var recordID: CKRecord.ID?
    var student: CKRecord.Reference?
    var value: Int?
    var date: Date?
    
    init() {
        
    }
    
    init(ckRecord: CKRecord) {
        self.student = ckRecord["student"]
        self.date = ckRecord["date"]
        self.value = ckRecord["value"]
        self.recordID = ckRecord.recordID
    }
    
    init(withValue value: Int, date: Date, andStudent student: CKRecord.Reference) {
        self.student = student
        self.value = value
        self.date = date
    }
}

