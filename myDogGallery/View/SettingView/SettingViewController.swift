//
//  SettingViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/31.
//

import UIKit
import KeychainSwift

class SettingViewController: BaseViewController {

    @IBAction func logoutButton(_ sender: Any) {
        logout()
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }

    @IBAction func cancelButton(_ sender: Any) {
    dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func logout() {
        let keychain = KeychainSwift()
        keychain.delete(Keys.id.rawValue)
        keychain.delete(Keys.name.rawValue)
        keychain.delete(Keys.email.rawValue)
    }
    
    func getVersion() -> String {
        let dictonary = Bundle.main.infoDictionary!
        let version = dictonary["CFBundleVersion"] as! String

        return "\(version)"
    }

}
extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return mainSettinglist.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainSettinglist[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingViewController", for: indexPath)
        var content = cell.defaultContentConfiguration()

        let target = mainSettinglist[indexPath.section].items[indexPath.row]

        switch indexPath.section {
        case 0:
            content.text = "\(target)"
            content.secondaryText = "최신버전: \(getVersion())"
        case 1:
            content.text = "\(target)"
        case 2:
            content.text = "\(target)"
        default:
           break
        }
        cell.contentConfiguration = content
        return cell
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "기본 설정"
        case 1:
            return "사용자 설정"
        case 2:
            return "기타 설정"
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let target = mainSettinglist[indexPath.section].items[indexPath.row]

        switch indexPath.section {
        case 0:
            print("")
        case 1:
            if target == "계정 / 정보 관리" {
                performSegue(withIdentifier: "etcSegue", sender: self)
            }
        case 2:
            if target == "공지사항" {
                performSegue(withIdentifier: "announcementSegue", sender: self)
            } else {
                performSegue(withIdentifier: "updateSegue", sender: self)
            }
        default:
           break
        }
    }
}
