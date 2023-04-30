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
    
    @IBAction func dateSelected(_ sender: UIDatePicker) {
        let dateSelected = sender.date
        print("###########",sender.date)
        print(yearFormatter.string(from: sender.date))
      
       
    }
    
//    var dateFormatter: DateFormatter = {
//        let birthDayDate = DateFormatter()
//        birthDayDate.dateFormat = "MMM d, yyyy"
//        birthDayDate.locale = Locale(identifier: "en_US_POSIX")
//
//        return birthDayDate
//    }()
    
    var yearFormatter: DateFormatter = {
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
    
   
           return yearFormatter
       }()
    
    
    
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = nameField.text, name.count > 0 else {
            return
        }
        
       
        let ageYearStr = yearFormatter.string(from: birthDayDatePicker.date)
        let currentYearStr = yearFormatter.string(from: Date())
        
        guard let ageInt = Int(ageYearStr), let currentInt = Int(currentYearStr) else { return }
            let age = currentInt - ageInt
        
        print("$#@!$#!@", age)
//        guard let ageStr = ageField.text, let age = Int(ageStr), age <= Int16.max else {
//            let alert = UIAlertController(title: "숫자가 너무 큽니다", message: "올바른 나이를 작성해주세요", preferredStyle: .alert)
//            let action = UIAlertAction(title: "확인", style: .cancel, handler: nil)
//            alert.addAction(action)
//            present(alert, animated:  true, completion:  nil)
//            return
//        }
        
        
        
        
        
        
        let isMale = genderSegmentedControl.selectedSegmentIndex == 0
        
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
       
        if let target = profileList {
            
            nameField.text = target.name
            ageLabel.text   = "\(target.age)"
            
            if target.gender {
                genderSegmentedControl.selectedSegmentIndex = 0
            } else {
                genderSegmentedControl.selectedSegmentIndex = 1
            }
            
            birthDayDatePicker.date = target.birthDay ?? Date()
            detailField.text = target.detail
            profileImage.image = UIImage(data: target.image!)
            
            navigationItem.title = "Profile Edit Page"
        } else {
            print("에러입니다")
        }
    }
    
    func presentPickerView() {
        var configuration = PHPickerConfiguration()
        configuration.filter = PHPickerFilter.images
        configuration.selectionLimit = 1
        
        let picker: PHPickerViewController = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated:  true, completion:  nil)
    }
}

extension ProfileEditTableViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        
        for item in results {
            item.itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let image = image as? UIImage {
                    print(image)
                    
                    DispatchQueue.main.async {
                        self.profileImage.image = image
                    }
                }
            }
        }
    }
}
