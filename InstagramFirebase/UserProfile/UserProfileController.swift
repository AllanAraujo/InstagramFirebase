//
//  UserProfileController.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/14/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
    
    var user: User?
    var isGridView = true
    let cellId = "cellId"
    let homePostCellId = "homePostCellId"
    let headerId = "headerId"
    var posts = [Post]()
    var isFinishedPaging = false
    var userId: String?
    


    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        fetchUser()
        
        //Also needed in order to create header section.
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homePostCellId)
        
        setupLogOutButton()
    }
    
    // MARK: Loging/Logout functions
    
    fileprivate func setupLogOutButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogOut))
    }
    
    @objc func handleLogOut() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            print("perform log out")
            do {
                try Auth.auth().signOut()
                
                //Need to present a loging controller
                let loginController = LoginController()
                let navigationController = UINavigationController(rootViewController: loginController)
                self.present(navigationController, animated: true, completion: nil)
                
            } catch let signOutErr {
                print("Failed to sign out: ", signOutErr)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            print("perform cancel")
        }))
        
        present(alertController, animated: true, completion: nil)
    }

    // MARK: Data Fetching methods
    
    fileprivate func fetchUser() {
        //Set uid to be whatever we pass in from somewhere else
        //OR we just look at the current UID
        //OR just set to blank ID
        let uid = userId ?? Auth.auth().currentUser?.uid ?? ""
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.username
            //Needed in order to show image. missed this in tutorial and image wasn't appearing.
            self.collectionView?.reloadData()
            self.paginatesPosts()
        }
    }
    
    fileprivate func fetchOrderedPosts() {
        guard let uid = user?.uid else {return}
        let ref = Database.database().reference().child("posts").child(uid)
        
        ref.queryOrdered(byChild: "creationDate").observe(.childAdded, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            
            guard let user = self.user else {return}
            
            let post = Post(user: user, dictionary: dictionary)
            self.posts.insert(post, at: 0)
            //self.posts.append(post)
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("failed to fetch ordered posts: ", err)
        }
    }
    

    
    
    fileprivate func paginatesPosts() {
        print("start paging for more posts")
        
        guard let uid = self.user?.uid else {return}
        let ref = Database.database().reference().child("posts").child(uid)
        
        var query = ref.queryOrdered(byChild: "creationDate")
        
        if posts.count > 0 {
        
            guard let value = posts.last?.creationDate.timeIntervalSince1970 else {return}
            query = query.queryEnding(atValue: value)
        }
        
        query.queryLimited(toLast: 4).observe(.value, with: { (snapshot) in
            
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            
            allObjects.reverse()
            
            if allObjects.count < 4 {
                self.isFinishedPaging = true
            }
            
            if self.posts.count > 0 && allObjects.count > 0 {
                //needed for issue of repeating the lead post
                allObjects.removeFirst()
            }
        
            guard let user = self.user else {return}
            
            allObjects.forEach({ (snapshot) in
                guard let dictionary = snapshot.value as? [String: Any] else {return}
                var post = Post(user: user, dictionary: dictionary)
                post.id = snapshot.key
                self.posts.append(post)
            })
            
//            self.posts.forEach({ (post) in
//                <#code#>
//            })
            
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("Failed to paginate posts:", err)
        }
    }

    // MARK: Collection View Handling
    func didChangeToGridView() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    func didChangeToListView() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // hot to fire off paginate call
        if indexPath.item == self.posts.count - 1  && !isFinishedPaging{
            print("paginating for posts")
            paginatesPosts()
        }
        
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item]
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homePostCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
            
        }
    }
    
    //setup actual square size for each view in collection.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //Subtracting -2 becuase without it, makes the view not actually split into three views equally in the collection view.
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8 //username userprofileimageview
            height += view.frame.width
            height += 50
            height += 60
            
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    //setup line spacing between each view to be 1. Effects being able to divide views equally
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    //Needed to customize header in profile page
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        
        //This works because we did two things:
        //1. Cast this whole function call with - as! UserProfileHeader
        //2. Created a var in UserProfileHeader for user.
        header.user = self.user
        header.delegate = self
        return header
    }
    
    //sets height of header. Must conform to UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
}


