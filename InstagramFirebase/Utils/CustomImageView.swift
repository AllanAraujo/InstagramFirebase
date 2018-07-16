//
//  CustomImageView.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/19/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit

//outside of class means accessible to all
var imageCache = [String: UIImage]()

class CustomImageView: UIImageView {
    
    var lastURLUsedToLoadImage: String?
    
    func loadImage(urlString: String){
        
        lastURLUsedToLoadImage = urlString
        
        //fixes image flickering when updating images
        self.image = nil
        
        //get image if already cached. Skip having to fetch. 
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        guard let url = URL(string: urlString) else {return}
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            if let err = err {
                print("failed to fetch user profile photoes", err)
            }
            
            //Fixes issue of repeating iamges being loaded
            if url.absoluteString != self.lastURLUsedToLoadImage {
                return
            }
            
            guard let imageData = data else {return}
            let photoImage = UIImage(data: imageData)
            
            //cache this
            imageCache[url.absoluteString] = photoImage
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
            //DONT FORGET TO CALL RESUME
            //IMAGES WONT LOAD IF FORGET THIS
            }.resume()
    }
}
