//
//  DetailPhotoViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/22.
//

import UIKit
import Photos

class DetailPhotoViewController: UIViewController {

    var asset: PHAsset?

    @IBOutlet var imageView: UIImageView!

    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }

    func load() {
        if let asset {
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat

            PHImageManager.default().requestImage(for: asset, targetSize: imageView.bounds.size, contentMode: .aspectFit, options: options) { image, _ in
                self.imageView.image = image
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        load()

        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }


//    func getAssetThumbnail(asset: PHAsset) -> UIImage {
//        let manager = PHImageManager.default()
//        let option = PHImageRequestOptions()
//        var thumbnail = UIImage()
//        option.isSynchronous = true
//        manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: option, resultHandler: {(result, info) -> Void in
//            if let result = result {
//                thumbnail = result
//            }
//        })
//        return thumbnail
//    }

}

extension DetailPhotoViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            guard let asset = self?.asset, let details = changeInstance.changeDetails(for: asset) else { return }

            self?.asset = details.objectAfterChanges

            if details.assetContentChanged {
                self?.load()
            }
        }
    }
}
