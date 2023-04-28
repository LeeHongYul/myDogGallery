//
//  MemoViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit

class MemoViewController: UIViewController {
    
    @IBOutlet var memoTableView: UITableView!
    
    @IBOutlet var memoTitleLabel: UILabel!
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
    
    var dateFormatter: DateFormatter = {
        let inputDateFormat = DateFormatter()
        inputDateFormat.dateFormat = "MMM d, yyyy"
        inputDateFormat.locale = Locale(identifier: "en_US_POSIX")
        
        return inputDateFormat
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .memoDidChange, object: nil, queue: .main) { noti in
            CoreDataManager.shared.fetchMemo()
            self.memoTableView.reloadData()
            
        }
        
        
        let searchBar1 = UISearchBar()
        searchBar1.placeholder = "제목을 검색해주세요"
        navigationItem.titleView = searchBar1
        
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar1: UISearchBar) {
        CoreDataManager.shared.searchByName(searchBar1.text)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CoreDataManager.shared.fetchMemo()
        memoTableView.reloadData()
        
    }
    
   
    
    
    
    
    
    
    
}

extension MemoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CoreDataManager.shared.memoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoViewController") as! MemoTableViewCell
        
        cell.memoTitleLabel?.text = CoreDataManager.shared.memoList[indexPath.row].title
        
        if let inputDateType = CoreDataManager.shared.memoList[indexPath.row].inputDate{
            cell.memoInputDateLabel.text = dateFormatter.string(from: inputDateType)
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
        
    }
}
