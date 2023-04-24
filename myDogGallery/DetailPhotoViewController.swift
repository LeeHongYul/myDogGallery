//
//  DetailPhotoViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/22.
//

import UIKit
import Photos

class DetailPhotoViewController: UIViewController {

    var editPhoto: PHAsset?
   
    @IBOutlet var imageView: UIImageView!
    
    @IBAction func close(_ sender: Any) {
    dismiss(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = getAssetThumbnail(asset: editPhoto!)
    }
    
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
            thumbnail = result!
        })
        return thumbnail
    }
    


}
