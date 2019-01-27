//
//  ViewController.swift
//  AprendendoCloudkit
//
//  Created by Elias Paulino on 25/01/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    @IBOutlet weak var postsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post]?
    var authors: [CKRecord.ID: Users]?
    
    var userReference: CKRecord.Reference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let postCellNib = UINib.init(nibName: "PostTableViewCell", bundle: Bundle.main  )
        self.tableView.register(postCellNib, forCellReuseIdentifier: "postCell")
        self.tableView.dataSource = self
        self.tableView.allowsSelection = false
        self.tableView.separatorStyle = .none
        
        NotificationService.shared.delegate = self
        
        CloudKitService.shared.discoverUserId(sucessCase: { (userReference) in
            self.userReference = userReference
            DispatchQueue.main.async {
                if self.postsSegmentedControl.selectedSegmentIndex == 0 {
                    self.loadAllPosts()
                } else {
                    self.loadPosts(fromUser: userReference)
                }
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
    
    func loadAllPosts() {
        let sortDescriptor = NSSortDescriptor.init(key: "date", ascending: false)
        
        Post.all(withSortDescriptors: [sortDescriptor], result: { (posts) in
            self.posts = posts
            
            self.loadAuthors(fromPosts: posts)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }, errorCase: { (error) in
            print(error)
        })
    }
    
    
    func loadPosts(fromUser userReference: CKRecord.Reference) {
        let sortDescriptor = NSSortDescriptor.init(key: "date", ascending: false)
        
        Post.findBy(field: "author", .equalTo, userReference, withSortDescriptors: [sortDescriptor], result: { (posts) in
            self.posts = posts
            
            self.loadAuthors(fromPosts: posts)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { (error) in
            print(error)
        }
    }
    
    
    /// Usa operations para buscar todos os autores dos posts já buscados em um so request
    ///
    /// - Parameter posts: os posts ja buscados
    func loadAuthors(fromPosts posts: [Post]?) {
        if let authorIDs = posts?.map({ (post) -> CKRecord.ID in
            
            return post.author!.recordID
        }) {
            let operation = CKFetchRecordsOperation.init(recordIDs: authorIDs)
            
            operation.fetchRecordsCompletionBlock = { (authorRecords, error) in
                self.authors = [:]
                
                //mapeia para um dicionario de array: users
                for (authorID, authorRecord) in authorRecords ?? [:] {
                    self.authors?[authorID] = Users.init(ckRecord: authorRecord)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            CKContainer.default().database(with: .public).add(operation)
        }
    }
    
    @IBAction func segmentedChanged(_ sender: Any) {
        if self.postsSegmentedControl.selectedSegmentIndex == 0 {
            self.loadAllPosts()
        } else if let userReference = self.userReference {
            self.loadPosts(fromUser: userReference)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController {
            if let addViewController = navigationController.viewControllers.first as? AddViewController {
                addViewController.userReference = self.userReference
                addViewController.delegate = self
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath)
        
        guard let post = self.posts?[indexPath.row],
              let title = post.title,
              let content = post.content,
              let postCell = cell as? PostTableViewCell,
              let authorID = post.author?.recordID else {
            return cell
        }
        
        if let authorName = self.authors?[authorID]?.name {
            postCell.setup(withTitle: title, andContent: content, authorName: authorName)
        } else {
            postCell.setup(withTitle: title, andContent: content)
        }
        
        return postCell
    }
}

extension ViewController: AddViewControllerDelegate {
    func postAdded(controller: AddViewController, post: Post) {
        self.posts?.insert(post, at: 0)
        self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .left)
    }
}

extension ViewController: NotificationServiceDelegate {
    func postHasArrived(post: Post) {
        self.posts?.insert(post, at: 0)
        self.tableView.insertRows(at: [IndexPath.init(row: 0, section: 0)], with: .left)
    }
}
