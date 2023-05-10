//
//  WalkHistoryTableViewCell.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/08.
//

import UIKit

class WalkHistoryTableViewCell: UITableViewCell {

    @IBOutlet var currentDateLabel: UILabel!
    
    @IBOutlet var currentDistanceLabel: UILabel!
    
    
    @IBOutlet var walkProfileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
