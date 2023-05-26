//
//  MemoViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit
import CoreData

class MemoViewController: UIViewController {
    let memoSearchBar = UISearchBar()
    var isSearchMode = false
    
    @IBOutlet var memoTableView: UITableView!
    @IBOutlet var memoTitleLabel: UILabel!
    
    var dateFormatter: DateFormatter = {
        let inputDateFormat = DateFormatter()
        inputDateFormat.dateFormat = "MMM d, yyyy"
        inputDateFormat.locale = Locale(identifier: "en_US_POSIX")
        
        return inputDateFormat
    }()
    
    /// Memo 내용을 수정하가 위한 세그웨이 코드
    /// - Parameters:
    ///   - segue: EditSegue
    ///   - sender: UITableViewCell
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditSegue" {
            if let cell = sender as? UITableViewCell, let indexPath = memoTableView.indexPath(for: cell) {
                let target = CoreDataManager.shared.memoList[indexPath.row]
                if let vc = segue.destination.children.first as? NewMemoViewController {
                    vc.editTarget = target
                }
            }
        }
    }
    
    /// 메모의 이름으로 검색하는 SearchBar
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        CoreDataManager.shared.searchByName(searchBar.text)
        memoTableView.reloadData()
        
        print("searchBar clicked")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(forName: .memoDidChange, object: nil, queue: .main) { noti in
            CoreDataManager.shared.fetchMemo()
            self.memoTableView.reloadData()
        }

        navigationItem.titleView = memoSearchBar
        memoSearchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memoSearchBar.placeholder = CoreDataManager.shared.memoList.count == 0 ? "메모를 작성해주세요" : "제목을 검색해 주세요"
        CoreDataManager.shared.fetchPredicate()
        memoTableView.reloadData()
    }
}

extension MemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode == false {
            return CoreDataManager.shared.memoList.count
        } else {
            return CoreDataManager.shared.list.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoViewController") as! MemoTableViewCell
        if isSearchMode == false {
            cell.memoTitleLabel?.text = CoreDataManager.shared.memoList[indexPath.row].title
            if let inputDateType = CoreDataManager.shared.memoList[indexPath.row].inputDate {
                cell.memoInputDateLabel.text = dateFormatter.string(from: inputDateType)
            }
        } else {
            let target = CoreDataManager.shared.list[indexPath.row]
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let target = CoreDataManager.shared.memoList[indexPath.row]
            CoreDataManager.shared.deleteMemo(memo: target)
            
            CoreDataManager.shared.fetchMemo()
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
