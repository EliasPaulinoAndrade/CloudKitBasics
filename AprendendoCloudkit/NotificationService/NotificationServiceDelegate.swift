//
//  NotificationServiceDelegate.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import Foundation

protocol NotificationServiceDelegate {
    func postHasArrived(post: Post)
}
