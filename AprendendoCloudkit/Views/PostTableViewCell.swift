//
//  PostTableViewCell.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 26/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var contentTextField: UILabel!
    @IBOutlet weak var titleTextField: UILabel!
    @IBOutlet weak var holderView: UIView!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.holderView.layer.cornerRadius = 10
        self.holderView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func setup(withTitle title: String, andContent content: String, authorName: String? = "Loading") {
        self.titleTextField.text = title
        self.contentTextField.text = content
        self.authorLabel.text = authorName
    }
}
