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
    
    var colabRecord: CKRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        colabTextView.delegate = self
        findByColab()
    }
    
    func findByColab() {
        Colab.all(result: { (records: [CKRecord]?) in
            self.colabRecord = records?.first
            DispatchQueue.main.async {
                self.colabTextView.text = self.colabRecord?["text"]
            }
        }) { (error) in
            self.showError()
        }
    }
    
    func showError() {
        let alertController = UIAlertController.init(title: "Error", message: "Any Bad Thing Happen", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction.init(title: "OK", style: .cancel, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }))
    }
}

extension ColabViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.colabRecord?["text"] = self.colabTextView.text
        
        if let colabRecord = self.colabRecord {
            CKContainer.default().database(with: .public).save(colabRecord) { (record, error) in }
        }
    }
}
