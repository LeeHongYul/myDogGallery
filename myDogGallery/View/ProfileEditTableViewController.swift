//
//  ProfileEditTableViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit
import PhotosUI

extension Notification.Name {
    static let profileDidInsert = Notification.Name(rawValue: "profileDidInsert")
    static let profileDidUpdate = Notification.Name(rawValue: "profileDidUpdate")
}

class ProfileEditTableViewController: UITableViewController {
    var profileList: ProfileEntity?
    @IBOutlet var nameField: UITextField!
    @IBOutlet var ageLabel: UILabel!
    @IBOutlet var genderSegmentedControl: UISegmentedControl!
    @IBOutlet var birthDayDatePicker: UIDatePicker!
    @IBOutlet var detailField: UITextField!
    @IBOutlet var profileImage: UIImageView!
    @IBAction func selectProfileImageBtn(_ sender: Any) {
        presentPickerView()
    }
    
    var yearFormatter: DateFormatter = {
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        return yearFormatter
    }()
    
    func addAlert(title: String, messageStr: String, actionTitleStr: String) {
        let alert = UIAlertController(title: title, message: messageStr, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitleStr, style: .cancel, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    ///  새로운 프로필 등록이나, 이미 등록된 프로필 내용 수정할때 필요한 코드
    @IBAction func save(_ sender: Any) {
        guard let name = nameField.text, name.count > 0 else {
            return
        }
        if name.count >= 11 {
            addAlert(title: "이름 글자수가 많습니다 10자", messageStr: "이름 글자수 수정 필요합니다.", actionTitleStr: "확인")
            return
        }
        let ageYearStr = yearFormatter.string(from: birthDayDatePicker.date)
        let currentYearStr = yearFormatter.string(from: Date())
        guard let ageInt = Int(ageYearStr), let currentInt = Int(currentYearStr) else { return }
        let age = currentInt - ageInt

        let isMale = genderSegmentedControl.selectedSegmentIndex

        let birthDay = birthDayDatePicker.date
        let detail = detailField.text
        let timeStamp = Date()
        guard let data = profileImage.image?.jpegData(compressionQuality: 0.75) else { return }
        if let target = profileList {
            CoreDataManager.shared.updateProfile(update: target, name: name, age: age, gender: isMale, birthDay: birthDay, detail: detail, image: data)
            NotificationCenter.default.post(name: .profileDidUpdate, object: nil)
        } else {
            CoreDataManager.shared.addNewProfile(name: name, age: age, gender: isMale, birthDay: birthDay, detail: detail, image: data, timeStamp: timeStamp)
            NotificationCenter.default.post(name: .profileDidInsert, object: nil)
        }
        dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //ProfileTableController에서 클릭한 프로필의 데이터 가져오기
        if let target = profileList {
            nameField.text = target.name
            ageLabel.text = "\(target.age)"
            if target.gender == 0 {
                genderSegmentedControl.selectedSegmentIndex = 0
            } else {
                genderSegmentedControl.selectedSegmentIndex = 1
            }
            birthDayDatePicker.date = target.birthDay ?? Date()
            detailField.text = target.detail
            profileImage.image = UIImage(data: target.image!)
            navigationItem.title = "Profile Edit Page"
        } else {
            print("error")
        }
    }
    //프로필 선택하는 뷰
    func presentPickerView() {
        var configuration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.images
        configuration.selectionLimit = 1
        let picker: PHPickerViewController = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
}

extension ProfileEditTableViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        for item in results {
            item.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self.profileImage.image = image
                    }
                }
            }
        }
    }
}
