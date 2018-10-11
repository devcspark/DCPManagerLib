//
//  PermissionPhotoViewController.swift
//  DCPManagerLib_sample
//
//  Created by ChunsooPark on 2018. 9. 21..
//  Copyright © 2018년 devcspark. All rights reserved.
//

import UIKit
import Photos
import DCPManagerLib

class miniPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage : UIImageView!
    
}

class PermissionPhotoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver {

    @IBOutlet weak var mainPhoto: UIImageView!
    @IBOutlet weak var photoCollection: UICollectionView!
    
    private var sizeofPhotos = CGSize()
    private var fetchResultOfAsset:PHFetchResult<PHAsset>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.

        // Reload the layout to get the size of the collection.
        view.layoutIfNeeded()
        let photoWidth = photoCollection.frame.width / 3.0
        sizeofPhotos = CGSize(width: photoWidth, height: photoWidth)
        
        // Require users to use Photos.
        DCPPermissionManager.shared().CheckPermission(permission: [.Photo]) { (isAccess) in
            
            if isAccess {
                PHPhotoLibrary.shared().register(self)
                
                // sort to creation date
                let fetchOption = PHFetchOptions()
                fetchOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                
                // reload collection when get result asset of album.
                self.fetchResultOfAsset = PHAsset.fetchAssets(with: .image, options: fetchOption)
                
                if self.fetchResultOfAsset!.count > 0 {
                    PHImageManager.default().requestImage(for: self.fetchResultOfAsset!.firstObject!,
                                                          targetSize: self.mainPhoto.frame.size,
                                                          contentMode: .aspectFill,
                                                          options: nil) { (image, _) in
                                                            self.mainPhoto.image = image
                    }
                }
                
                self.photoCollection.reloadData()
                
            }else{
                // If you can not get permission, go to the previous screen.
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Button action
    @IBAction func pressedBack(_ sender: UIButton) {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchResultOfAsset == nil {
            return 0
        }else{
            return fetchResultOfAsset!.count
        }
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell:miniPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "reusePhoto", for: indexPath) as! miniPhotoCell
        
        PHImageManager.default().requestImage(for: fetchResultOfAsset![indexPath.row],
                                              targetSize: sizeofPhotos,
                                              contentMode: .aspectFill,
                                              options: nil) { (image, _) in
            cell.photoImage.image = image
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        PHImageManager.default().requestImage(for: fetchResultOfAsset![indexPath.row],
                                              targetSize: mainPhoto.frame.size,
                                              contentMode: .aspectFill,
                                              options: nil) { (image, _) in
                                                self.mainPhoto.image = image
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeofPhotos
    }

    // MARK: - PHPhotoLibraryChangeObserver
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let changeAsset = changeInstance.changeDetails(for: fetchResultOfAsset!) {
            fetchResultOfAsset = changeAsset.fetchResultAfterChanges
            DispatchQueue.main.async {
                self.photoCollection.reloadData()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
