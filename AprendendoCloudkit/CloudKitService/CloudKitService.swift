//
//  CloudKitService.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitService {
    static let shared = CloudKitService.init()
    
    private init() {
        
    }
    
    
    /// Busca pelas informcações pessoais do usuario logado e as salva na nuvem no recordType do usuario
    ///
    /// - Parameters:
    ///   - container: o container
    ///   - database: a database na qual salvar
    public func requestUserInfo(container: CKContainer = CKContainer.default(),
                                database: CKDatabase = CKContainer.default().database(with: .public)) {
        
        CKContainer.default().requestApplicationPermission(.userDiscoverability) { (status, error) in
            
            //verifica existencia da chave alreadySet, se as informacoes do usuario já estiverem salvar, isso
            //não é refeito,
            if let _ = UserDefaults.standard.string(forKey: "alreadySet") {
                
                return
            } else {
                UserDefaults.standard.set("alreadySet", forKey: "alreadySet")
            }
            
            if status == .granted {
                //se a autorização foi sucedida, modifica o record de usuario para inserir o nome do usuario.
                self.getUserIdentity(sucessCase: { (identity) in
                    guard let userID = identity?.userRecordID else {
                        return
                    }
                    
                    database.fetch(withRecordID: userID, completionHandler: { (record, error) in
                        if let _ = error {
                            return
                        }
                        
                        if let userRecord = record {
                            userRecord["name"] = identity?.nameComponents?.givenName
                            
                            database.save(userRecord, completionHandler: { (userRecord, error) in
                                
                            })
                        }
                       
                    })
                    
                }, errorCase: { (error) in })
            }
        }
    }
    
    
    /// Descobre a identidade(informacoes pessoais) do usuário logado no icloud
    ///
    /// - Parameters:
    ///   - container: o container
    ///   - sucessCase: completionde sucesso
    ///   - errorCase: completion de erro
    public func getUserIdentity(container: CKContainer = CKContainer.default(),
                            sucessCase: @escaping (CKUserIdentity?) -> (),
                            errorCase: @escaping (Error?) -> ()) {
        
        discoverUserId(container: container, sucessCase: { (userReference) in
            container.discoverUserIdentity(withUserRecordID: userReference.recordID, completionHandler: { (identity, error) in
                sucessCase(identity)
            })
        }) { (error) in
            errorCase(error)
        }
    }
    
    
    /// Descobre o ID do usuario logado no iCloud
    ///
    /// - Parameters:
    ///   - container: o container
    ///   - sucessCase: caso de sucesso
    ///   - errorCase: caso de erro
    func discoverUserId(
        container: CKContainer = CKContainer.default(),
        sucessCase: @escaping (CKRecord.Reference) -> (),
        errorCase: @escaping (Error?) -> ()) {
        
        container.fetchUserRecordID { (userId, error) in
            if let error = error {
                errorCase(error)
                return
            }
            
            if let authorId = userId {
                let userReference = CKRecord.Reference.init(recordID: authorId, action: .none)
                sucessCase(userReference)
                
            } else {
                errorCase(nil)
            }
        }
    }
}
