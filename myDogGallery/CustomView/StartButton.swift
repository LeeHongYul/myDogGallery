//
//  StartButton.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/06/12.
//

import UIKit

class StartButton: UIButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setInit()
    }

    func setInit() {
        self.layer.borderColor = UIColor.systemGray.cgColor
        self.layer.borderWidth = 0.8
        self.layer.cornerRadius = 10
    }
}
