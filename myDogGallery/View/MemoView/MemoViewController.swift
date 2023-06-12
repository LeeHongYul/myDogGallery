//
//  MemoViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit
import CoreData

class MemoViewController: BaseViewController {
    let memoSearchBar = UISearchBar()
    var isSearchMode = false // isSearchMode 변수에 따라 memolist을 불러올지 검색된 리스트를 불러올지 결정하는 변수
    
    @IBOutlet var memoTableView: UITableView!
    
    // Memo 내용을 수정하가 위한 세그웨이 코드
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue", let cell = sender as? UITableViewCell, let indexPath = memoTableView.indexPath(for: cell) {
                let target = MemoManager.shared.memoList[indexPath.row]
                if let viewController = segue.destination.children.first as? NewMemoViewController {
                    viewController.editTarget = target
            }
        }
    }
    
    // 메모의 이름으로 검색하는 SearchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        MemoManager.shared.searchByName(searchBar.text)
        memoTableView.reloadData()
        
        print("searchBar clicked")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: .memoDidChange, object: nil, queue: .main) { noti in
            MemoManager.shared.fetchMemo()
            self.memoTableView.reloadData()
        }

        navigationItem.titleView = memoSearchBar
        memoSearchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memoSearchBar.placeholder = MemoManager.shared.memoList.count == 0 ? "메모를 작성해주세요" : "제목을 검색해 주세요"
        MemoManager.shared.fetchSearchedMemo()
        memoTableView.reloadData()
    }
}

extension MemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isSearchMode ? MemoManager.shared.searchBarlist.count : MemoManager.shared.memoList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoViewController") as! MemoTableViewCell
        if isSearchMode == false {
            cell.memoTitleLabel?.text = MemoManager.shared.memoList[indexPath.row].title
            if let inputDateType = MemoManager.shared.memoList[indexPath.row].inputDate {
                cell.memoInputDateLabel.text = inputDateType.dateToString(format: "MMM d, yyyy")
            }
        } else {
            let target = MemoManager.shared.searchBarlist[indexPath.row]
            if let title = target.value(forKey: "title") as? String {
                cell.memoTitleLabel?.text  = "\(title)"
            }
        }
        return cell
    }
}

extension MemoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    // Memo delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let target = MemoManager.shared.memoList[indexPath.row]
            MemoManager.shared.deleteMemo(memo: target)
            
            MemoManager.shared.fetchMemo()
            memoTableView.reloadData()
        }
    }
}

extension MemoViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            isSearchMode = false
            DispatchQueue.main.async {
                self.memoTableView.reloadData()
            }
        } else {
            isSearchMode = true
        }
    }
}
