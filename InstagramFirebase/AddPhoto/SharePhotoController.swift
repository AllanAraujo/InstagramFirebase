//
//  SharePhotoController.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/18/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Firebase

class SharePhotoController: UIViewController {
    
    //The moment this happens, we can catch it in the app somehwere, anywhere we want. WE do this in omecontroller.
    //This is used to update UI automatically when user posts.
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        
        setupImageAndTextViews()
    }

    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        view.addSubview(imageView)
        view.addSubview(textView)
        
        
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleShare( ){
        guard let caption = textView.text, caption.count > 0 else {return}
        guard let image = selectedImage else {return}
        guard let uploadData = UIImageJPEGRepresentation(image, 0.5) else {return}
        
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        let filename = NSUUID().uuidString
        Storage.storage().reference().child("posts").child(filename).putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Failed to upload post image: ", err)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
            guard let imageURL = metadata?.downloadURL()?.absoluteString else {return}
            
            print("Successfully uploaded post image: ", imageURL)
            
            self.saveToDatabaseWithImageURL(imageUrl: imageURL)
        }
    }
    
    fileprivate func saveToDatabaseWithImageURL(imageUrl: String) {
        guard let postImage = selectedImage else {return}
        guard let caption = textView.text else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let userPostRef = Database.database().reference().child("posts").child(uid)
        
        //useful for having a refernce to a location whevaluee a list of user "things" are stored
        let ref = userPostRef.childByAutoId()
        
        let values = ["imageUrl": imageUrl, "caption": caption, "imageWidth": postImage.size.width, "imageHeight": postImage.size.height, "creationDate": Date().timeIntervalSince1970] as [String : Any]
        
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print("failed to upload post to DB", err)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
            print("successfully saved post to DB")
            self.dismiss(animated: true, completion: nil)
            
            
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
