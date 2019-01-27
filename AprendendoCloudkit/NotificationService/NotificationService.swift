//
//  NotificationService.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import UserNotifications

class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService.init()
    
    var delegate: NotificationServiceDelegate?
    
    private override init() {
        
    }
    
    
    /// Pergunta ao usuario sobre a permissao para notificacoes remotas
    func requestPushAuth() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                self.getPushSettings()
            }
        }
    }
    
    
    /// verifica autorização para envio de notificacoes remotas e as registra
    func getPushSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    
    /// É chamado quando uma notificação está prestes a ser mostrada, aqui o record modificado na nuvem é
    /// buscado, e enviado pelo delegate, que deve trata-lo
    ///
    /// - Parameters:
    ///   - center: o notification center
    ///   - notification: a notification contendo informacoes, por exemplo, o corpo na notificacao
    ///   - completionHandler: chamado para dar continuidade ao fluxo da notificacao
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let ckNotification = CKQueryNotification.init(fromRemoteNotificationDictionary: notification.request.content.userInfo)
        
        if let recordID = ckNotification.recordID {
            Post.findBy(field: "recordID", .equalTo, recordID, result: { (posts: [Post]?) in
                if let post = posts?.first {
                    
                    DispatchQueue.main.async {
                        self.delegate?.postHasArrived(post: post)
                    }
                }
            }) { (error) in
                print(error)
            }
        }
        
        return completionHandler([])
    }
    
    
    /// Busca as subscripts da nuvem, verifica se a subscript que observa novas postagens já está criada
    /// se não estiver, a cria com um ID reconhecivel
    public func setupSubscription() {
        CKContainer.default().publicCloudDatabase.fetchAllSubscriptions { (subscriptions, error) in
            if let error = error {
                print(error)
                return
            }
            
            var registered = false
            subscriptions?.forEach({ (subscription) in
                if subscription.subscriptionID == "PostSub" {
                    registered = true
                }
            })
            
            if !registered {
                let subscription = CKQuerySubscription.init(recordType: "Post", predicate: NSPredicate.init(value: true), subscriptionID: "PostSub", options: .firesOnRecordCreation)
                
                let notification = CKSubscription.NotificationInfo.init()
                notification.alertBody = ""
                notification.shouldBadge = true
                notification.shouldSendContentAvailable = true
                
                subscription.notificationInfo = notification
                
                CKContainer.default().publicCloudDatabase.save(subscription) { (subscription, error) in }
            }
        }
    }
}
