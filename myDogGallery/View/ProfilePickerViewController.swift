//
//  ProfilePickerViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/13.
//

import UIKit

class ProfilePickerViewController: UIViewController {

    var pickedFinalImage: UIImage?
    @IBOutlet var profileCollectionView: UICollectionView!
    @IBOutlet var profileImagePicker: UIImageView!
    @IBOutlet var profileImageContainerView: RoundedView!

    @IBOutlet var starWalkButton: UIButton!


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
    func shadowOrange(inputView: UIView) {
        inputView.layer.shadowColor = UIColor.systemOrange.cgColor
        inputView.layer.shadowOpacity = 0.9
        inputView.layer.shadowRadius = 40
        inputView.layer.shadowOffset = CGSize(width: 0, height: 1)
        inputView.layer.shadowPath = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .orange
        CoreDataManager.shared.fetchProfile()

        let conditionalLayout = UICollectionViewCompositionalLayout { sectionIndex, env in

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))

            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
//            section.orthogonalScrollingBehavior = .groupPaging
            return section

        }

        profileCollectionView.collectionViewLayout = conditionalLayout
        profileCollectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        profileCollectionView.reloadData()


    }


}


extension ProfilePickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreDataManager.shared.profileList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePickCollectionViewCell", for: indexPath) as! ProfilePickCollectionViewCell

            let target = CoreDataManager.shared.profileList[indexPath.row]

            cell.profilePickImage.image = UIImage(data: target.image!)

            return cell

    }


}


extension ProfilePickerViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let target = CoreDataManager.shared.profileList[indexPath.row]

        profileImagePicker.image = UIImage(data: target.image!)

        pickedFinalImage = UIImage(data: target.image!)
//        pickedFinalImage?.images = UIImage(data: target.image!)

    }
}
