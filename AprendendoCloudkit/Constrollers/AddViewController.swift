//
//  AddViewController.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit
import CloudKit

class AddViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    var userReference: CKRecord.Reference?
    
    var delegate: AddViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        contentTextView.layer.cornerRadius = 5
        contentTextView.layer.masksToBounds = true
        
    }

    @IBAction func saveTapped(_ sender: Any) {
        if let userReference = self.userReference,
           let title = self.titleTextField.text,
           let content = self.contentTextView.text {
        
            let post = Post.init(withTitle: title, content: content, date: Date.init(), andAuthor: userReference)
            
            post.save(result: { (post) in
                if let post = post {
                    self.dismiss(animated: true, completion: {
                        self.delegate?.postAdded(controller: self, post: post)
                    })
                }
            }) { (error) in
                self.showError()
            }
        }
    }
    
    func showError() {
        let alertController = UIAlertController.init(title: "Error", message: "Any Bad Thing Happen", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
