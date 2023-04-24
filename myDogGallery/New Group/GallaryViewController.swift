//
//  GallaryViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit
import Photos

class GallaryViewController: UIViewController {
    
    let imageManager = PHCachingImageManager()
    
    var asset: PHFetchResult<PHAsset>
    
    init() {

        let phFetchOptions = PHFetchOptions()
        phFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        self.asset = PHAsset.fetchAssets(with: phFetchOptions)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    @IBOutlet var collectionView: UICollectionView!
    private let cellWidth = (UIScreen.main.bounds.width - 20) / 3
    private let kPhotoCell = "PhotoCollectionViewCell"
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func cancelButton(_sender: Any) {
        dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cancelButton = UIButton(frame: CGRect(x: 50, y: 50, width: 50, height: 50))
        cancelButton.setTitle("되냐", for: .normal)
        cancelButton.backgroundColor = .orange
        self.view.addSubview(cancelButton)
        
        
        
        
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, env in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/4), heightDimension:  .fractionalHeight(1.0))

            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 5)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 50, leading: 30, bottom: 0, trailing: 0)

            return section
            
        }
        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: kPhotoCell, bundle: nil), forCellWithReuseIdentifier: kPhotoCell)
    }
}

extension GallaryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return asset.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPhotoCell, for: indexPath) as! PhotoCollectionViewCell
        
        let asset = self.asset[indexPath.item]
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: cellWidth, height: cellWidth), contentMode: .aspectFill, options: nil) { image, _ in
            
            if cell.representedAssetIdentifier == asset.localIdentifier {
                
                cell.imageView.image = image
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let target = asset[indexPath.item]
        
        
        
        print(target)
    }
}
