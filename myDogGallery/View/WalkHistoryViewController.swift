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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueMapDetail" {
            if let cell = sender as? UITableViewCell, let indexPath = walkHistoryTableview.indexPath(for: cell) {
                let target = CoreDataManager.shared.walkList[indexPath.row]

                if (segue.destination.sheetPresentationController?.detents = [.medium()]) != nil, let vc = segue.destination as? MapDetailViewController {
                        vc.fristLat = target.startLat
                        vc.fristLon = target.startLon
                        vc.secondLat = target.endLat
                        vc.secondLon = target.endLon
                        vc.walkDetailImage = UIImage(data: target.profile!)
                        vc.walkDetail = target.totalDistance
                        vc.walkDistance = target.totalTime
                }
            }
        }
    }

//    @objc func showDetail(_ sender: Any?) {
//        performSegue(withIdentifier: "detailSegue", sender: sender)
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        segue.destination.sheetPresentationController?.detents = [.medium(), .large()]
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.fetchWalk()
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
        CoreDataManager.shared.walkList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalkHistoryTableViewCell") as! WalkHistoryTableViewCell
        let target = CoreDataManager.shared.walkList[indexPath.row]
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
        let target = CoreDataManager.shared.walkList[indexPath.row]

        print(target.startLat, "SASASASAAAAAAAAAAAAAAAAAA")
        print(target.startLon, "SASABBBBBBBBBBBBBBBB")
        print(target.endLat, "SASAAAAAAAAAAAAAAAAAAA")
        print(target.endLon, "SASBBBBBBBBBBBBBBBB")
    }
}
