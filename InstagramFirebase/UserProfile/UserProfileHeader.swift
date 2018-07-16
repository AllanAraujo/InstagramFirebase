//
//  UserProfileHeader.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/15/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Firebase


protocol UserProfileHeaderDelegate {
    func didChangeToListView()
    func didChangeToGridView()
}


class UserProfileHeader: UICollectionViewCell {
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        didSet {
            guard let profileImageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(urlString: profileImageUrl)
            usernameLabel.text = user?.username
            
            setupEditFollowButton()
        }
    }

    var numberOfFollowing = 0
    var numberOfFollowers = 0
    var numberOfPosts = 0
    
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        return image
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.addTarget(self, action: #selector(handleChangeToGridView), for: .touchUpInside)
        return button
    }()
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        button.addTarget(self, action: #selector(handleChangeToListView), for: .touchUpInside)
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    lazy var postsLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var followersLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing)\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var editFollowProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupProfileImageView()
        setupBottomToolbar()
        setupUsernameLabel()
        setupUperStatsView()
        setupEditProfileButton()
        setupUserStats()
        
    }

    @objc func handleChangeToListView(){
        print("changing to list view")
        listButton.tintColor = .mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToListView()
    }
    
    @objc func handleChangeToGridView() {
        print("changing to grid view")
        gridButton.tintColor = .mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.2)
        delegate?.didChangeToGridView()
    }
    

    fileprivate func setupEditProfileButton(){
        addSubview(editFollowProfileButton)
        editFollowProfileButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 34)
    }
    
    fileprivate func setupUperStatsView() {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        
        stackView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
    }
    
    
    fileprivate func setupUsernameLabel() {
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: gridButton.topAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0)
    }
    
    fileprivate func setupProfileImageView() {
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.clipsToBounds = true
    }
    
    fileprivate func setupBottomToolbar() {
        
        let topDividerView = UIView()
        topDividerView.backgroundColor = UIColor.lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = UIColor.lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    fileprivate func setupUserStats() {
        getNumberOfPosts()
        getNumberOfFollowing()
    }
    
    fileprivate func getNumberOfFollowing() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(currentLoggedInUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            self.numberOfFollowing = Int(snapshot.childrenCount)
            let attributedText = NSMutableAttributedString(string: "\(self.numberOfFollowing)\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
            self.followingLabel.attributedText = attributedText
        }) { (err) in
            print("unable to retrieve user following count")
        }
    }
    
    fileprivate func getNumberOfPosts() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("posts").child(currentLoggedInUserId).observeSingleEvent(of: .value, with: { (snapshot) in
            self.numberOfPosts = Int(snapshot.childrenCount)
            let attributedText = NSMutableAttributedString(string: "\(self.numberOfPosts)\n", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.foregroundColor: UIColor.lightGray, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14)]))
            self.postsLabel.attributedText = attributedText
        }) { (err) in
            print("unable to retrieve user following count")
        }
    }
    
    fileprivate func setupEditFollowButton() {
        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else {return}
        
        //ID of selected user. can be different from current user, say if we selected from search.
        guard let userId = user?.uid else {return}
        
        if currentLoggedInUserId == userId {
            //edit profile
        } else {
            
            //check if following
            Database.database().reference().child("following").child(currentLoggedInUserId).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.editFollowProfileButton.setTitle("Unfollow", for: .normal)
                    
                } else {
                    self.setupFollowStyle()
                }
            }) { (err) in
                print("failed ot check if following: ", err)
            }
            
        }
    }
    
    @objc func handleEditProfileOrFollow() {
        
        guard let currentLoggedINUSerID = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        
        if editFollowProfileButton.titleLabel?.text == "Unfollow" {
            //unfollow
            Database.database().reference().child("following").child(currentLoggedINUSerID).child(userId).removeValue { (err, ref) in
                if let err = err {
                    print("failed to unfollow: ", err)
                    return
                }
                
                print("successfully unfollwed user: ", self.user?.username ?? "")
                self.setupFollowStyle()
            }
            
        } else {
            //follow
            let ref = Database.database().reference().child("following").child(currentLoggedINUSerID)
            
            let values = [userId: 1]
            ref.updateChildValues(values) { (err, ref) in
                if let err = err {
                    print("failed to follow user: ", err)
                    return
                }
                print("successfully followed user: ", self.user?.username ?? "")
                
                self.editFollowProfileButton.setTitle("Unfollow", for: .normal)
                self.editFollowProfileButton.backgroundColor = .white
                self.editFollowProfileButton.setTitleColor(.black, for: .normal)
                
            }
        }
    }
    
    fileprivate func setupFollowStyle() {
        self.editFollowProfileButton.setTitle("Follow", for: .normal)
        self.editFollowProfileButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        self.editFollowProfileButton.setTitleColor(.white, for: .normal)
        self.editFollowProfileButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
