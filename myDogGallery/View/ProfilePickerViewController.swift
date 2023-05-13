//
//  ProfilePickerViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/13.
//

import UIKit

class ProfilePickerViewController: UIViewController {


    var pickedFinalImage: UIImage?

    @IBOutlet var profileImagePicker: UIImageView!


    @IBOutlet var profileImagePickerView: UIPickerView!


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profilePickerSegue" {
            if let nextViewController = segue.destination as? MapViewController {
                if let selectedItem = sender as? UIImage {
                    nextViewController.selectedItem = selectedItem // 다음 뷰 컨트롤러로 데이터 전달
                }
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.fetchProfile()


    }

    override func viewWillAppear(_ animated: Bool) {
        profileImagePickerView.reloadAllComponents()
    }
    
    @IBAction func profileSaveBtn(_ sender: Any) {




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
            return "프로필을 등록해주세요"
        } else {
            let target = CoreDataManager.shared.profileList[row]
            return target.name
        }

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        let target = CoreDataManager.shared.profileList[row]
//        testTextField.text = target.name

        let dataImage = UIImage(data: target.image!)

        profileImagePicker.image = dataImage
        performSegue(withIdentifier: "profilePickerSegue", sender: dataImage)
    }




}
