//
//  ProfilePickerViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/13.
//

import UIKit

class ProfilePickerViewController: UIViewController {

    var pickedFinalImage: UIImage?

    @IBOutlet var startWalkView: RoundedView!
    @IBOutlet var profileImagePicker: UIImageView!
    @IBOutlet var profileImageContainerView: RoundedView!
    @IBOutlet var profileImagePickerView: UIPickerView!
    @IBOutlet var saveProfileBtn: UIButton!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profilePickerSegue" {

                if let destinationVC = segue.destination as? MapViewController {

                        destinationVC.pickedFinalImage = pickedFinalImage
            }
        }
    }

    func shadow(inputView: UIView) {
        inputView.layer.shadowColor = UIColor.lightGray.cgColor
        inputView.layer.shadowOpacity = 1
        inputView.layer.shadowRadius = 2
        inputView.layer.shadowOffset = CGSize(width: 5, height: 5)
        inputView.layer.shadowPath = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        CoreDataManager.shared.fetchProfile()
        saveProfileBtn.isEnabled = false
        shadow(inputView: profileImageContainerView)
        shadow(inputView: startWalkView)
    }

    override func viewWillAppear(_ animated: Bool) {
        profileImagePickerView.reloadAllComponents()


    }
    
    @IBAction func saveProfileBtn(_ sender: Any) {

    }

}

extension ProfilePickerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        if CoreDataManager.shared.profileList.count == 0 {
           return 1
        } else {
            return  CoreDataManager.shared.profileList.count
        }
    }
}

extension ProfilePickerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if CoreDataManager.shared.profileList.count == 0 {
            return "산책 시킬 반려견을 선택해 주세요"
        } else {
            let target = CoreDataManager.shared.profileList[row]
            return target.name
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let target = CoreDataManager.shared.profileList[row]
//        testTextField.text = target.name
        saveProfileBtn.isEnabled = true
        profileImagePicker.image = UIImage(data: target.image!)
        pickedFinalImage = UIImage(data: target.image!)

    }
}
