//
//  PhotoCollectionViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/22.
//

import UIKit
import Photos
import PhotosUI

// private let reuseIdentifier = "cell"

class PhotoCollectionViewController: UICollectionViewController, PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        func photoLibraryDidChange(_ changeInstance: PHChange) {
            DispatchQueue.main.async { [weak self] in
                self?.fetch()
            }
        }
    }

    @IBOutlet var photoCollectionView: UICollectionView!

    var allPhotos: PHFetchResult<PHAsset>!
    let imageManager = PHCachingImageManager()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoSegue" {
            if let cell = sender as? UICollectionViewCell, let indexPath = photoCollectionView.indexPath(for: cell) {
                let target = allPhotos.object(at: indexPath.item)
                if let viewController = segue.destination.children.first as? DetailPhotoViewController {
                    viewController.asset = target
                }
            }
        }
    }

    //    @IBAction func reloadPhoto(_ sender: Any) {
    //        fetchAllPhotos()
    //    }


    //    func fetchAllPhotos() {
    //        let allPhotosOptions = PHFetchOptions()
    //        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    //        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
    //
    //        self.photoCollectionView?.reloadData()
    //    }

    lazy var dataSource: UICollectionViewDiffableDataSource<Int, PHAsset> = {
        return UICollectionViewDiffableDataSource(collectionView: photoCollectionView) { collectionView, indexPath, asset in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyPhotoCollectionViewCell", for: indexPath) as! MyPhotoCollectionViewCell

            cell.representedAssetIdentifier = asset.localIdentifier
            cell.imageView.image = nil //이전 이미지 남아았을수도있어서 초기화

            self.imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil) { image, _ in
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    //없으면 예전셀에 들어갈수도있음, 잘못된 이미지 안들어감, 급작스럽게 교체 안됨
                    cell.imageView.image = image
                }
            }

            return cell
        }
    }()

    func fetch() {
        var assets = [PHAsset]()

        var options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let result = PHAsset.fetchAssets(with: options)
        result.enumerateObjects { asset, index, _ in
            assets.append(asset)

            var snapshot = NSDiffableDataSourceSnapshot<Int, PHAsset>()
            snapshot.appendSections([0]) //numberofsectiond이랑 비슷

            snapshot.appendItems(assets)

            self.dataSource.apply(snapshot)
        }
    }

        func createLayout() -> UICollectionViewLayout {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            let layout = UICollectionViewCompositionalLayout(section: section)

            return layout

        }

    override func viewDidLoad() {
        super.viewDidLoad()
//        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
//        case .notDetermined:
//            print("not determined")
//            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
//                switch status {
//                case .authorized, .limited:
//                    DispatchQueue.main.async {
//                        self.fetch()
//                    }
//                case .denied:
//                    print("")
//                default:
//                    print("그 밖의 권한이 부여 되었습니다.")
//                }
//            }
//        case .restricted:
//            print("restricted")
//        case .denied:
//            print("")
//        case .limited, .authorized:
//            self.fetch()
//        default:
//            print("")
//        }

        photoCollectionView.collectionViewLayout = createLayout()
        fetch()
        //        let conditionalLayout = UICollectionViewCompositionalLayout { sectionIndex, env in
        //            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        //            let item = NSCollectionLayoutItem(layoutSize: itemSize)
        ////            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        //            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
        //            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        //            let section = NSCollectionLayoutSection(group: group)
        ////            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        //            return section
        //        }
        //        photoCollectionView.collectionViewLayout = conditionalLayout
        //        photoCollectionView.reloadData()

        PHPhotoLibrary.shared().register(self)
    }


    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }


//        override func numberOfSections(in collectionView: UICollectionView) -> Int {
//            return 1
//        }
//
//        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//            if PHPhotoLibrary.authorizationStatus(for: .addOnly) == .authorized {
//                return allPhotos.count
//            } else {
//                return 0
//            }
//        }
//        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyPhotoCollectionViewCell", for: indexPath) as! MyPhotoCollectionViewCell
//            let asset = allPhotos.object(at: indexPath.item)
//            cell.representedAssetIdentifier = asset.localIdentifier
//            imageManager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
//                if cell.representedAssetIdentifier == asset.localIdentifier {
//                    cell.imageView.image = image
//                }
//            })
//            return cell
//        }
    }

