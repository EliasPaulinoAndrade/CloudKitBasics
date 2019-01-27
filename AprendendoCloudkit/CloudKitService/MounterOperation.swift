//
//  MounterOperations.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation



/// operacoes que o predicate mounter pode construir
enum MounterOperation: String, CustomStringConvertible {
    
    var description: String {
        return rawValue
    }
    
    case lessThen = "<"
    case biggerThen = ">"
    case biggerOrEqualThen = ">="
    case lessOrEqualThen = "<="
    case equalTo = "=="
}
