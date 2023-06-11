//
//  ProfilePickerViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/13.
//

import UIKit

class WalkProfileViewController: UIViewController {
    
    var pickedFinalImage: UIImage? // 선택 프로필 이미지를 MapViewController로 넘기기 위한 변수
    var didSelectedProfileCell = false // 프로필을 선택하지 않은 상태에서 MapViewController로 전환을 방지하기 위한 변수
    @IBOutlet var selectedProfileImage: UIImageView!
    
    @IBOutlet var profileImageContainerView: RoundedView!
    @IBOutlet var profileCollectionView: UICollectionView!
    
    @IBOutlet var starWalkButton: UIButton!
    
    func addAlert(title: String, messageStr: String, actionTitleStr: String) {
        let alert = UIAlertController(title: title, message: messageStr, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitleStr, style: .cancel, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // 선택한 프로필의 이미지를 MapViewController의 Annotation으로 보내기 위한 코드
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if didSelectedProfileCell == false {
            addAlert(title: "프로필을 선택해주세요.", messageStr: "프로필을 선택하지 않았습니다.", actionTitleStr: "확인")
            return
        } else {
            if segue.identifier == "profilePickerSegue" {
                
                if let destinationViewController = segue.destination as? MapViewController {
                    
                    destinationViewController.pickedFinalImage = pickedFinalImage
                }
            }
        }
    }

    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        //            section.orthogonalScrollingBehavior = .groupPaging
        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = .orange
        ProfileManager.shared.fetchProfile()

        profileCollectionView.collectionViewLayout = createLayout()
        profileCollectionView.reloadData()
    }

    // 추가된 프로필을 CollectionView에 넣기 위해 reload
    override func viewWillAppear(_ animated: Bool) {
        profileCollectionView.reloadData()
    }
}

extension WalkProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProfileManager.shared.profileList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePickCollectionViewCell", for: indexPath) as! ProfilePickCollectionViewCell
        
        let target = ProfileManager.shared.profileList[indexPath.row]

        if let targetImage = target.image {
            cell.profilePickImage.image = UIImage(data: targetImage)
        }

        return cell
    }
}

extension WalkProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let target = ProfileManager.shared.profileList[indexPath.row]
        didSelectedProfileCell = true
        if let targetImage = target.image {
            selectedProfileImage.image = UIImage(data: targetImage)
            pickedFinalImage = UIImage(data: targetImage)
        }
    }
}
