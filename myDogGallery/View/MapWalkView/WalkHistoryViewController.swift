//
//  WalkHistoryViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/08.
//

import UIKit

class WalkHistoryViewController: UIViewController {
    
    var pickedFinalImage: UIImage?
    
    @IBOutlet var walkHistoryTableview: UITableView!

    // 산책 정보 데이터 MapDetailView로 넘기기
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueMapDetail" {
            if let cell = sender as? UITableViewCell, let indexPath = walkHistoryTableview.indexPath(for: cell) {
                let target = WalkManger.shared.walkList[indexPath.row]
                
                if (segue.destination.sheetPresentationController?.detents = [.medium()]) != nil, let viewController = segue.destination as? MapDetailViewController {

                    viewController.walkHistory = target
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        WalkManger.shared.fetchWalk()
    }
    var dateFormatter: DateFormatter = {
        let inputDate = DateFormatter()
        inputDate.dateFormat = "yyyy.MM.dd"
        inputDate.locale = Locale(identifier: "en_US_POSIX")
        return inputDate
    }()
    
}

extension WalkHistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        WalkManger.shared.walkList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalkHistoryTableViewCell") as! WalkHistoryTableViewCell

        let target = WalkManger.shared.walkList[indexPath.row]

        cell.currentDateLabel?.text = dateFormatter.string(from: target.currentDate!)
        let result = target.totalDistance / 1000
        
        cell.walkProfileImageView.image = UIImage(data: target.profile ?? Data())
        cell.currentDistanceLabel?.text = String(format: "%.2f Km", result)
        cell.currentTimeLabel.text = target.totalTime
        return cell
    }
}

extension WalkHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let target = WalkManger.shared.walkList[indexPath.row]
    }
}
