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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataManager.shared.profileList.count
    }
    
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
        
        cell.birthdayLabel.text = dateFormatter.string(for: target.birthDay)
        cell.detailLabel.text = target.detail
        cell.profileImage.image = UIImage(data: target.image ?? Data())
        cell.profileImage.contentMode = .scaleAspectFill
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let target = CoreDataManager.shared.profileList[indexPath.row]
            CoreDataManager.shared.deleteProfile(profile: target)
            
            CoreDataManager.shared.fetchProfile()
            profileListTableView.reloadData()
        }
        
        
    }
    
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
