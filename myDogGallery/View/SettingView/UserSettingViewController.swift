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
    var keychainlist = [String]()

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
        
//        let targetID = keychainlist[indexPath.row]

//        print(targetID.count)

        cell.textLabel?.text  = target
//        cell.detailTextLabel?.text = targetID

        return cell
    }

}
// extension UserSettingViewController: ASAuthorizationControllerDelegate {
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        // 키 체인을 사용하여 데이터가 저장되어 있는지 확인한 후, 해당 데이터를 사용하여 사용자 이름을 mainLabel에 표시
//        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            let id = credential.user
//            let email = credential.email
//            let fullName = credential.fullName?.formatted() ?? "방문객님"
//
//            let keychain = KeychainSwift()
//
//            keychain.set(id, forKey: Keys.id.rawValue)
//            keychainlist.append(id)
//            if let email {
//                keychain.set(email, forKey: Keys.email.rawValue)
//                keychainlist.append(email)
//            }
//
//            if let fullName = credential.fullName?.formatted(), fullName.count > 0 {
//                keychain.set(fullName, forKey: Keys.name.rawValue)
//                keychainlist.append(fullName)
//            }
//
//        }
//    }
//}
