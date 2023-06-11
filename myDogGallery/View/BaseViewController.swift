//
//  BaseViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/06/12.
//

import Foundation
import UIKit

class BaseViewController : UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .orange
    }

    func showErrorAlert(){

    }

    func showAlert(titile : String,
                   message : String ,
                   confrimTitle: String = "확인" ,
                   cancelTitle : String = "취소",
                   callback: ()->() ,
                   cancelCallback : ()->()) {
        let alert = UIAlertController(title: titile, message: message, preferredStyle: .alert)

        let alertAction = UIAlertAction(title: confrimTitle, style: .default)

        let cancleAction = UIAlertAction(title: cancelTitle, style: .cancel)

        alert.addAction(alertAction)

        self.present(alert, animated: true )
    }
}
