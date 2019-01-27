//
//  TestViewController.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit
import CloudKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        Post.findBy(field: "title", .equalTo, "haha", result: { (posts) in
            
            if var post = posts?.first {
                post.title = "testinho123"
                
                post.save(result: { (post) in
                    
                    print(post)
                }, errorCase: { (error) in
                    print(error)
                })
            }
    
            print(posts)
        }) { (error) in
            print(error)
        }
    }
}
