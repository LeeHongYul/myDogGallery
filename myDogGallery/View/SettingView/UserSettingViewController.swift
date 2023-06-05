//
//  UserSettingViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/06/04.
//

import UIKit
import KeychainSwift
import AuthenticationServices

class UserSettingViewController: UIViewController {

    let list = ["이메일", "휴대폰 번호", "이름"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .orange
    }
}

extension UserSettingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserSettingViewController", for: indexPath)

        let target = list[indexPath.row]

        cell.textLabel?.text  = target
        cell.detailTextLabel?.text = "등록"

        return cell
    }
}
