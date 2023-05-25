//
//  PhotoCollectionViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/22.
//

import UIKit
import Photos
import PhotosUI

private let reuseIdentifier = "cell"

class PhotoCollectionViewController: UICollectionViewController {
    @IBOutlet var photoCollectionView: UICollectionView!
    var allPhotos: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoSegue" {
            if let cell = sender as? UICollectionViewCell, let indexPath = photoCollectionView.indexPath(for: cell) {
                let target = allPhotos.object(at: indexPath.item)
                if let vc = segue.destination.children.first as? DetailPhotoViewController {
                    vc.editPhoto = target
                }
            }
        }
    }
    func fetchAllPhotos() {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
        
        self.photoCollectionView?.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .notDetermined:
            print("not determined")
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                switch status {
                case .authorized, .limited:
                    DispatchQueue.main.async {
                        self.fetchAllPhotos()
                    }
                case .denied:
                    print("")
                default:
                    print("그 밖의 권한이 부여 되었습니다.")
                }
            }
        case .restricted:
            print("restricted")
        case .denied:
            print("")
        case .limited, .authorized:
            self.fetchAllPhotos()
        default:
            print("")
        }
        let conditionalLayout = UICollectionViewCompositionalLayout { sectionIndex, env in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .absolute(100))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            return section
        }
        photoCollectionView.collectionViewLayout = conditionalLayout
        photoCollectionView.reloadData()
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if PHPhotoLibrary.authorizationStatus(for: .addOnly) == .authorized {
            return allPhotos.count
        } else {
            return 0
        }
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyPhotoCollectionViewCell
        let asset = allPhotos.object(at: indexPath.item)
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.imageView.image = image
            }
        })
        return cell
    }
}
