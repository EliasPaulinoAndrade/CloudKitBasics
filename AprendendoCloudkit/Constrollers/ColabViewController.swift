//
//  ColabViewController.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit
import CloudKit

class ColabViewController: UIViewController {

    @IBOutlet weak var colabTextView: UITextView!
    
    var colabSemaphore = DispatchSemaphore.init(value: 1)
    var colabRecord: CKRecord?
    var lastColabText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        colabTextView.delegate = self
        findByColab { (record) in
            self.colabRecord = record
            self.lastColabText = self.colabRecord?["text"]
            
            DispatchQueue.main.async {
                self.colabTextView.text = self.colabRecord?["text"]
            }
        }
    }
    
    func findByColab(completion: ((CKRecord?) -> ())? = nil) {
        Colab.all(result: { (records: [CKRecord]?) in
            completion?(records?.first)
        }) { (error) in
            self.showError()
        }
    }
    
    func showError() {
        let alertController = UIAlertController.init(title: "Error", message: "Any Bad Thing Happen", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
}

extension ColabViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        
        self.colabRecord?["text"] = self.colabTextView.text
        
        self.findByColab { (record) in
            self.colabRecord = record
            DispatchQueue.main.async {
                self.colabTextView.text = self.colabRecord?["text"]
            }
            
            if let colabRecord = self.colabRecord {
                
                DispatchQueue.global(qos: .background).async {
                    self.colabSemaphore.wait()
                    CKContainer.default().database(with: .public).save(colabRecord) { (record, error) in
                        DispatchQueue.main.async {
                            if let _ = error {
                                
                                self.showError()
                                
                                return
                            }
                            self.colabTextView.text = record?["text"]
                        }
                        self.colabSemaphore.signal()
                    }
                }
            }
            
        }
    }
}
