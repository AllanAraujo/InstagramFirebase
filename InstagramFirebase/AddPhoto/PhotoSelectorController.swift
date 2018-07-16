//
//  PhotoSelectorController.swift
//  InstagramFirebase
//
//  Created by Allan Araujo on 6/18/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import Photos

class PhotoSelectorController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let cellId = "cellId"
    let headerId = "headerId"
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage: UIImage?
    var header: PhotoSelectorHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        
        setupNavigationButtons()
        
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.register(PhotoSelectorHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerId)
        
        fetchPhotos()
        
    }
    
    fileprivate func setupNavigationButtons() {
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNext() {
        let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = header?.photoImageView.image
        navigationController?.pushViewController(sharePhotoController, animated: true)
    }
    
    fileprivate func assetFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 30
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescriptor]
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: assetFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image {
                        self.images.append(image)
                        //Do this because we want to RE_FETCH whatever image we click on
                        //We re-fetch because we dont want to lose image qulaity when displaying image in header view
                        self.assets.append(asset)
                        
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                    }
                    //only call reload as soon as done fetching all images
                    if count == allPhotos.count - 1 {
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
                    }
                })
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.item]
        collectionView.reloadData()
        let indexPath = IndexPath(item: 0, section: 0)
        //scrolls to top when selected
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    //Must tell app how big header needs to be or wont display at all
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerId, for: indexPath) as! PhotoSelectorHeader
        
        //hold on to refernce for header. Useful for passing onto Share view
        self.header = header
        
        //Can so this bc we cast with as! PhotoSelectorHeader
        header.photoImageView.image = selectedImage
        
        let imageManager = PHImageManager.default()
        //This is part of logic to set header image to be better qulaity than smaller views.
        if let selectedImage = selectedImage {
            if let index = self.images.index(of: selectedImage){
                let selectedAsset = self.assets[index]
                let targetSize = CGSize(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    header.photoImageView.image = image
                }
            }
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PhotoSelectorCell
        
        cell.photoImageView.image = images[indexPath.item]
        
        return cell
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
