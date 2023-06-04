//
//  GridViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/06/01.
//

import UIKit
import Photos

class PhotoViewController: UIViewController {

    let imageManager = PHImageManager() //이미지나 영상 읽어올때

    @IBOutlet var photoCollectionView: UICollectionView!

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "PhotoSegue" {
//            if let cell = sender as? UICollectionViewCell, let indexPath = photoCollectionView.indexPath(for: cell) {
//                let target = .object(at: indexPath.item)
//                if let vc = segue.destination as? DetailPhotoViewController {
//                    vc.editPhoto = target
//                }
//            }
//        }
//    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "PhotoSegue":
            if let viewController = segue.destination.children.first as? DetailPhotoViewController {
                viewController.asset = sender as? PHAsset
            }
        default:
            break
        }
    }


    lazy var dataSource: UICollectionViewDiffableDataSource<Int, PHAsset> = {
        return UICollectionViewDiffableDataSource(collectionView: photoCollectionView) { collectionView, indexPath, asset in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell

            cell.targetAssetId = asset.localIdentifier
            cell.imageView.image = nil // 이전 이미지 남아았을수도있어서 초기화

            self.imageManager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: nil) { image, _ in
                if cell.targetAssetId == asset.localIdentifier {
                    // 없으면 예전셀에 들어갈수도있음, 잘못된 이미지 안들어감, 급작스럽게 교체 안됨
                    cell.imageView.image = image
                }
            }

            return cell
        }
    }()

    func fetch() {
        var assets = [PHAsset]()

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

            let result = PHAsset.fetchAssets(with: options)
            result.enumerateObjects { asset, index, _ in
                assets.append(asset)
            }

        var snapshot = NSDiffableDataSourceSnapshot<Int, PHAsset>()
        snapshot.appendSections([0]) // numberofsectiond이랑 비슷

        snapshot.appendItems(assets)

        dataSource.apply(snapshot)

    }

    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
        photoCollectionView.collectionViewLayout = createLayout()
        PHPhotoLibrary.shared().register(self)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

}

extension PhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        guard let asset = dataSource.itemIdentifier(for: indexPath) else { return }
        switch asset.playbackStyle {
        case .image, .livePhoto:
            performSegue(withIdentifier: "PhotoSegue", sender: asset)
        case .unsupported:
            performSegue(withIdentifier: "livePhotosSegue", sender: asset)
        case .video:
            performSegue(withIdentifier: "videoSegue", sender: nil)
        default:
            break
        }
    }
}

extension PhotoViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            self?.fetch()
        }
    }
}
