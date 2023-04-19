//
//  MemoViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit

class MemoViewController: UIViewController {
    
    @IBOutlet var memoTableView: UITableView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: .memoDidChange, object: nil, queue: .main) { noti in
            CoreDataManager.shared.fetchMemo()
            self.memoTableView.reloadData()
            
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoViewController")!
        
        cell.textLabel?.text = CoreDataManager.shared.memoList[indexPath.row].title
        cell.detailTextLabel?.text = CoreDataManager.shared.memoList[indexPath.row].context
        
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
