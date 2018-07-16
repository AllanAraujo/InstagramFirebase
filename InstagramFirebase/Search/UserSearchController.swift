//
//  UserSearchController.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/21/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Firebase

class UserSearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    let cellId = "cellId"
    var users = [User]()
    var filteredUsers = [User]()
    
    //needs to be lazy var or can't call self
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Enter Username"
        sb.barTintColor = .gray
        //weird way of getting search bar to be diff color.
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor.rgb(red: 230, green: 230, blue: 230)
        sb.delegate = self
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        navigationController?.navigationBar.addSubview(searchBar)
        
        let navbar = navigationController?.navigationBar
        
        searchBar.anchor(top:navbar?.topAnchor, left: navbar?.leftAnchor, bottom: navbar?.bottomAnchor, right: navbar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.alwaysBounceVertical = true
        collectionView?.keyboardDismissMode = .onDrag
        
        fetchUsers()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = self.users.filter { (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            }
        }
        self.collectionView?.reloadData()
    }
    
    fileprivate func fetchUsers() {
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in

            guard let dictionaries = snapshot.value as? [String: Any] else {return}
            dictionaries.forEach({ (key, value) in
                if key == Auth.auth().currentUser?.uid {
                    //found myself in list. return. no need ot display self in search
                    return
                }
                
                guard let userDictionary = value as? [String: Any] else {return}
                //look at DB. You will see key is the UID
                let user = User(uid: key, dictionary: userDictionary)
                self.users.append(user)
            })
            
            self.users.sort(by: { (u1, u2) -> Bool in
                return u1.username.compare(u2.username) == .orderedAscending
            })
            self.filteredUsers = self.users
            self.collectionView?.reloadData()
            
        }) { (err) in
            print("failed to fetch users for search: ", err)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.isHidden = false
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchBar.isHidden = true
        //hides keyboard once row selected
        searchBar.resignFirstResponder()
        
        let user = filteredUsers[indexPath.item]
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileController.userId = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}
