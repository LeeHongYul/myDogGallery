//
//  ProfileTableViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit

class ProfileTableViewController: UITableViewController {
    var editProfileList: ProfileEntity?
    @IBOutlet var profileListTableView: UITableView!
    var dateFormatter: DateFormatter = {
        let birthDayDate = DateFormatter()
        birthDayDate.dateFormat = "MMM d, yyyy"
        birthDayDate.locale = Locale(identifier: "en_US_POSIX")
        return birthDayDate
    }()

    /// 등록한 프로필의 내용을 수정하기 위한 코드
    /// - Parameters:
    ///   - segue: EditProfileSegue으로 ProfileEditTableViewController 연결
    ///   - sender: UITableViewCell
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditProfileSegue" {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
                let target = CoreDataManager.shared.profileList[indexPath.row]
                if let vc = segue.destination.children.first as? ProfileEditTableViewController {
                    vc.profileList = target
                }
            }
        }
    }

    /// 프로필을 등록하거나 수정할 때 NotificationCenter을 활용한다.
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.fetchProfile()
        NotificationCenter.default.addObserver(forName: .profileDidInsert, object: nil, queue: .main) { noti in
            CoreDataManager.shared.fetchProfile()
            self.profileListTableView.reloadData()
        }
        NotificationCenter.default.addObserver(forName: .profileDidUpdate, object: nil, queue: .main) { noti in
            CoreDataManager.shared.fetchProfile()
            self.profileListTableView.reloadData()
        }
    }

    /// 등록한 프로필의 수 가져오기
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataManager.shared.profileList.count
    }

    /// 등록한 프로필의 이미지, 이름, 나이, 성별 표시한다
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell") as! ProfileTableViewCell
        let target = CoreDataManager.shared.profileList[indexPath.row]

        cell.nameLabel.text = target.name
        cell.ageLabel.text = "\(target.age) 살"
        if target.gender == true {
            cell.genderLabel.text = "Boy"
        } else {
            cell.genderLabel.text = "Girl"
        }

        cell.profileImage.image = UIImage(data: target.image ?? Data())
        cell.profileImage.contentMode = .scaleAspectFill
        return cell
    }

    /// 등록된 프로필 삭제하고 TablevView reload하는 코드
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let target = CoreDataManager.shared.profileList[indexPath.row]
            CoreDataManager.shared.deleteProfile(profile: target)
            CoreDataManager.shared.fetchProfile()
            profileListTableView.reloadData()
        }
    }

    /// 등록되어 있는 프로필은 Pin으로 상단에 고정할 수 있도록 했다.
    /// Pin을 사용하면 CoreData에서 fetchProfileByPin을 활용하여 Pin순서로 Profile을 불러오고 아니면 fetchProfile 으로 불러온다
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let target = CoreDataManager.shared.profileList[indexPath.row]
        let actionPin = UIContextualAction(style: .normal, title: "", handler: { action, view, completionHaldler in
            if target.pin == false {
                target.pin = true
                CoreDataManager.shared.fetchProfileByPin()
            } else {
                target.pin = false
                CoreDataManager.shared.fetchProfile()
            }
            self.profileListTableView.reloadData()
            CoreDataManager.shared.saveContext()
            completionHaldler(true)
        })
        actionPin.image = UIImage(systemName: "pin")
        if target.pin == true {
            actionPin.backgroundColor = .blue
            actionPin.image = UIImage(systemName: "pin.fill")
        }
        return UISwipeActionsConfiguration(actions: [actionPin])
    }
}
