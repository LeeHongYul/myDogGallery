//
//  WalkHistoryViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/08.
//

import UIKit


class WalkHistoryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.fetchWalk()
        CoreDataManager.shared.fetchProfile()
       
    }
    
    var dateFormatter: DateFormatter = {
        let inputDate = DateFormatter()
        inputDate.dateFormat = "EEEE, MMM d, yyyy"
        inputDate.locale = Locale(identifier: "en_US_POSIX")
        
        return inputDate
    }()


}

extension WalkHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CoreDataManager.shared.walkList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalkHistoryTableViewCell") as! WalkHistoryTableViewCell
        let target = CoreDataManager.shared.walkList[indexPath.row]
        
        cell.currentDateLabel?.text = dateFormatter.string(from:  target.currentDate!)
        
        let result = target.totalDistance / 1000
      
        cell.currentDistanceLabel?.text = String(format: "%.2f Km", result)
        
       
        
        return cell
    }
    
    
}
