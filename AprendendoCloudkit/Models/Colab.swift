//
//  Colab.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import CloudKit

struct Colab: CloudObject {
    
    var recordID: CKRecord.ID?
    var text: String?
    
    init() {
        
    }
    
    init(ckRecord: CKRecord) {
        self.text = ckRecord["text"]
        self.recordID = ckRecord.recordID
    }
    
    init(withText text: String) {
        self.text = text
    }
}
