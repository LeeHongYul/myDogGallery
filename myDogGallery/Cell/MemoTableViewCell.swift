//
//  MemoTableViewCell.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/26.
//

import UIKit

class MemoTableViewCell: UITableViewCell {
    
    @IBOutlet var memoTitleLabel: UILabel!
    @IBOutlet var memoInputDateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
