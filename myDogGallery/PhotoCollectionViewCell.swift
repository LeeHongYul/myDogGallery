//
//  PhotoCollectionViewCell.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    var representedAssetIdentifier: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
