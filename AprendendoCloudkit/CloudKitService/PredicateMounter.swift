//
//  PredicateMounter.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import CloudKit



/// Tem a funcao de montar NSPredicates simples
class PredicateMounter<T: CloudObject> {
    var parts: [PredicatePart] = []
    
    init(field: String,
         _ operation: MounterOperation,
         withValue value: Any) {
        
        self.and(field: field, operation, withValue: value)
        
    }
    
    
    /// Inclui mais um parametro no predicate
    ///
    /// - Parameters:
    ///   - field: o campo do parametro
    ///   - value: o valor do campo
    /// - Returns: retorna o mounter atual
    @discardableResult
    func and(field: String,
             _ operation: MounterOperation,
             withValue value: Any) -> PredicateMounter {
        
        let part = PredicatePart.init(field: field, operation: operation, value: value)
        parts.append(part)
        
        return self
    }
    
    
    /// Transforma as partes adicionadas no mounter em um NSPredicate
    ///
    /// - Returns: o predicate
    func nsPredicate() -> NSPredicate {
        var predicateString = ""
        var predicateArguments: [Any] = []
        
        parts.enumerated().forEach { (index, part) in
            predicateString.append(" %K \(part.operation) %@ ")
            predicateArguments.append(contentsOf: [part.field, part.value])
            if index != parts.endIndex.advanced(by: -1) {
                predicateString.append("AND")
            }
        }
        
        return NSPredicate.init(format: predicateString, argumentArray: predicateArguments)
    }
    
    
    /// Realiza a busca por meio do NSPredicate montado
    ///
    /// - Parameters:
    ///   - database: a database na qual procurar, padrao é a publica do container padrao
    ///   - result: a completion de sucess
    ///   - errorCase: a completion de erro
    func run(inDatabase database: CKDatabase = CKContainer.default().publicCloudDatabase,
             withSortDescriptors sortDescriptors: [NSSortDescriptor] = [],
             result: @escaping ([T]?) -> (),
             errorCase: @escaping (Error) -> ()) {
        
        let predicate = self.nsPredicate()
        let query = CKQuery.init(recordType: T.defaultRecordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                errorCase(error)
                return
            }
            
            result(
                records?.map({ (record) -> T in
                    return T.init(ckRecord: record)
                })
            )
        }
    }
    
    /// Realiza a busca por meio do NSPredicate montado
    ///
    /// - Parameters:
    ///   - database: a database na qual procurar, padrao é a publica do container padrao
    ///   - result: a completion de sucess
    ///   - errorCase: a completion de erro
    func run(inDatabase database: CKDatabase = CKContainer.default().publicCloudDatabase,
             withSortDescriptors sortDescriptors: [NSSortDescriptor] = [],
             result: @escaping ([CKRecord]?) -> (),
             errorCase: @escaping (Error) -> ()) {
        
        let predicate = self.nsPredicate()
        let query = CKQuery.init(recordType: T.defaultRecordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                errorCase(error)
                return
            }
            
            result(records)
        }
    }
    
    struct PredicatePart {
        var field: String
        var operation: MounterOperation
        var value: Any
    }
}



