//
//  ViewController.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/13/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    //Adds little effect of changing signup button to darker blue when form is filled
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && usernameTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            signupButton.isEnabled = true
            signupButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        } else {
            signupButton.isEnabled = false
            signupButton.backgroundColor = UIColor.rgb(red: 144, green: 204, blue: 244)
        }
    }
    
    let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 144, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 14),
                                                                                  NSAttributedStringKey.foregroundColor: UIColor.mainBlue()]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        view.addSubview(alreadyHaveAccountButton)
        
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 0, width: 0, height: 50)
        
        setupInputFields()
        
    }
    
    @objc func handleAlreadyHaveAccount() {
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func setupInputFields() {
        let stackview = UIStackView(arrangedSubviews: [emailTextField, usernameTextField, passwordTextField, signupButton])
        
        stackview.distribution = .fillEqually
        stackview.axis = .vertical
        stackview.spacing = 10
        
        view.addSubview(stackview)
        
        stackview.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
    }
    
    @objc func handleSignUp() {
        
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let username = usernameTextField.text, username.count > 0 else { return }
        guard let password = passwordTextField.text, password.count > 0 else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print("failed to create user: ", err)
                return
            }
            print("successfully created user: ", user?.uid ?? "")

            guard let image = self.plusPhotoButton.imageView?.image else { return }
            guard let uploadData = UIImageJPEGRepresentation(image, 0.3) else { return }
            let fileName = NSUUID().uuidString
            //create subfolder "profile_images" which will have the images there. Each with unique ID
            Storage.storage().reference().child("profile_images").child(fileName).putData(uploadData, metadata: nil, completion: { (metadata, err) in
                if let err = err {
                    print("Failed to upload profile iamge: ", err)
                    return
                }
                
                guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else { return }
                
                print("Successfully uploaded profile image: ", profileImageUrl)
                
                guard let uid = user?.uid else { return }
                
                guard let fcmToken = Messaging.messaging().fcmToken else {
                    print("cant get fcmToken...")
                    return
                }
                let dictionaryValues = ["username": username, "profileImageUrl": profileImageUrl, "fcmToken": fcmToken]
                let values = [uid: dictionaryValues]
                
                Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if let err = err {
                        print("Failed to save user info into db", err)
                    }
                    
                    print("saved user info into DB")
                    
                    //This allows you to refresh view with correct users info
                    //And we can do this bc in AppDelegate we set rootview as maintabbarcontroller
                    guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
                    mainTabBarController.setupViewControllers()
                    
                    self.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        
        //this is necessary in order to actual get photo once user selects.
        //also need to conform to delegate.
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        dismiss(animated: true, completion: nil)
    }
}
