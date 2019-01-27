//
//  CloudCodable.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 25/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import CloudKit


/// um objeto que pode se convertido para ckrecord e tem funções que facilitam manuseio do banco na nuvem
protocol CloudObject {
    
    var recordID: CKRecord.ID? { get set }
    init()
    init(ckRecord: CKRecord)
    func ckRecord(withRecordType recordType: String?) -> CKRecord
}


extension CloudObject {
    
    static var defaultRecordType: String {
        return String(describing: self)
    }
    
    
    /// Transforma um CloudObject em ckrecord
    ///
    /// - Parameter recordType: o record type do objeto na nuvem, padrão é o nome da propria classe
    /// - Returns: o ckrecord
    func ckRecord(withRecordType recordType: String? = nil) -> CKRecord {
        var record = CKRecord.init(recordType: recordType ?? Self.defaultRecordType)
        
        if let recordID = self.recordID {
            record = CKRecord.init(recordType: recordType ?? Self.defaultRecordType, recordID: recordID)
        }
        
        let mirror = Mirror.init(reflecting: self)
        
        mirror.children.forEach { (child) in
            if  let atributteName = child.label,
                let recordAtributte = child.value as? __CKRecordObjCValue {
                
                record[atributteName] = recordAtributte
            }
        }
        
        return record
    }
    
    
    /// Deleta um objeto da nuvem por meio do seu ID, se o objeto não tiver ID, o metodo não funcionará
    ///
    /// - Parameters:
    ///   - database: a database da qual deletar, padrão é a publica do container padrão
    ///   - result: completion com o resultado
    ///   - errorCase: completion com erro
    func delete(fromDatabase database: CKDatabase = CKContainer.default().publicCloudDatabase,
                result: @escaping (CKRecord.ID?) -> (),
                errorCase: @escaping (Error?) -> ()) {
        
        guard let recordID = self.recordID else {
            result(nil)
            return
        }
        
        database.delete(withRecordID: recordID, completionHandler: { (recordId, error) in
            if let error = error {
                errorCase(error)
                return
            }
            
            if let objectID = recordId {
                result(objectID)
                return
            }
            
            result(nil)
        })
    }
    
    
    /// Salva um ckrecord na nuvem
    ///
    /// - Parameters:
    ///   - database: a database em que salvar, padrão é a publica do container padrao
    ///   - result: completion de sucesso
    ///   - errorCase: completion de erro
    func save(inDatabase database: CKDatabase = CKContainer.default().publicCloudDatabase,
              result: @escaping (Self?) -> (),
              errorCase: @escaping (Error?) -> ()) {
        
        let record = self.ckRecord()
        
        database.save(record) { (record, error) in
            
            if let error = error {
                errorCase(error)
                return
            }
            
            if let postRecord = record {
                result(
                    Self.init(ckRecord: postRecord)
                )
                return
            }

            result(nil)
        }        
    }
    
    
    /// Busca um objeto pelo ID
    ///
    /// - Parameters:
    ///   - id: o id do objeto
    ///   - database: a database em que buscar
    ///   - result: completion de resultado
    ///   - errorCase: completion de erro
    static func get(byID id: CKRecord.ID, inDatabase
                    database: CKDatabase = CKContainer.default().publicCloudDatabase,
                    result: @escaping (Self?) -> (),
                    errorCase: @escaping (Error?) -> ()) {
    
        database.fetch(withRecordID: id, completionHandler: { (record, error) in
            if let error = error {
                errorCase(error)
                return
            }
            
            if let objectRecord = record {
                result(Self.init(ckRecord: objectRecord))
                return
            }
            
            result(nil)
        })
    }
    
    /// Busca objetos de um tipo na nuvem por meio de um parametro
    ///
    /// - Parameters:
    ///   - field: o nome do field parametro para busca
    ///   - value: o valor base desse field
    ///   - database: a database na qual procurar, padrao é a publica do container padrao
    ///   - result: completion de sucesso
    ///   - errorCase: completion de erro
    static func findBy(field: String,
                       _ operation: MounterOperation,
                       _ value: Any,
                       inDatabase database: CKDatabase = CKContainer.default().publicCloudDatabase,
                       withSortDescriptors sortDescriptors: [NSSortDescriptor] = [],
                       result: @escaping ([CKRecord]?) -> (),
                       errorCase: @escaping (Error) -> ()) {
        
        let mounter = PredicateMounter<Self>.init(field: field, operation, withValue: value)
        mounter.run(inDatabase: database, withSortDescriptors: sortDescriptors, result: result, errorCase: errorCase)
    }
    
    /// Busca objetos de um tipo na nuvem por meio de um parametro
    ///
    /// - Parameters:
    ///   - field: o nome do field parametro para busca
    ///   - value: o valor base desse field
    ///   - database: a database na qual procurar, padrao é a publica do container padrao
    ///   - result: completion de sucesso
    ///   - errorCase: completion de erro
    static func findBy(field: String,
                _ operation: MounterOperation,
                _ value: Any,
                inDatabase database: CKDatabase = CKContainer.default().publicCloudDatabase,
                withSortDescriptors sortDescriptors: [NSSortDescriptor] = [],
                result: @escaping ([Self]?) -> (),
                errorCase: @escaping (Error) -> ()) {
     
        let mounter = PredicateMounter<Self>.init(field: field, operation, withValue: value)
        mounter.run(inDatabase: database, withSortDescriptors: sortDescriptors, result: result, errorCase: errorCase)
    }
    
    
    /// Busca objetos na nuvem por meio de parametros
    ///
    /// - Parameters:
    ///   - field: o campo parametro para busca
    ///   - value: o valor base do campo
    /// - Returns: um predicate mounter, existe a possibilidade de incluir mais de um parametro na busca, no fim execute .run()
    static func findBy(field: String,
                       _ operation: MounterOperation,
                       _ value: Any) -> PredicateMounter<Self> {
        
        let mounter = PredicateMounter<Self>.init(field: field, operation, withValue: value)
        return mounter
    }
    
    /// Busca todos os objetos de um tipo no banco
    ///
    /// - Parameters:
    ///   - database: a database na qual procurar, padrao é a publica do container padrao
    ///   - result: completion de sucesso
    ///   - errorCase: completion de erro
    static func all(inDatabase database: CKDatabase = CKContainer.default().publicCloudDatabase,
                    withSortDescriptors sortDescriptors: [NSSortDescriptor] = [],
                    result: @escaping ([CKRecord]?) -> (),
                    errorCase: @escaping (Error) -> ()) {
        let predicate = NSPredicate.init(value: true)
        let query = CKQuery.init(recordType: Self.defaultRecordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                errorCase(error)
                return
            }
            
            result(records)
        }
    }
    
    /// Busca todos os objetos de um tipo no banco
    ///
    /// - Parameters:
    ///   - database: a database na qual procurar, padrao é a publica do container padrao
    ///   - result: completion de sucesso
    ///   - errorCase: completion de erro
    static func all(inDatabase database: CKDatabase = CKContainer.default().publicCloudDatabase,
                    withSortDescriptors sortDescriptors: [NSSortDescriptor] = [],
                    result: @escaping ([Self]?) -> (),
                    errorCase: @escaping (Error) -> ()) {
        let predicate = NSPredicate.init(value: true)
        let query = CKQuery.init(recordType: Self.defaultRecordType, predicate: predicate)
        query.sortDescriptors = sortDescriptors
        
        database.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                errorCase(error)
                return
            }
            
            result(
                records?.map({ (record) -> Self in
                    return Self.init(ckRecord: record)
                })
            )
        }
    }
}

//struct CloudCoder {
//    func decode<T: CloudObject>(fromRecord record: CKRecord, fromClass: T.Type) throws -> T {
//        var decodedObject = T.init()
//        let mirror = Mirror.init(reflecting: decodedObject)
//
//        var tempDict: [String: Any] = [:]
//
//        for attr in mirror.children {
//            if let attrName = attr.label,
//               let recordValue = record[attrName] {
//                tempDict[attrName] = recordValue
//
//                //setAssociatedObject_glue()
//                //decodedObject[keyPath: \T.title]
//                //let a = String.init()
//
//            }
//        }
//
//        //let json = try JSONSerialization.data(withJSONObject: tempDict)
//        //decodedObject = try JSONDecoder().decode(fromClass.self, from: json)
//
//        return decodedObject
//    }
//}
