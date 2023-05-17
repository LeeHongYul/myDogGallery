//
//  MapViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/01.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var pickedFinalImage: UIImage?
    
    @IBOutlet var playBtnView: RoundedView!

    @IBOutlet var mapGradientView: UIView!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var getLocationBtn: UIButton!
    @IBOutlet var kmeterLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    let locationManager = CLLocationManager()
    var previousCoordinate: CLLocationCoordinate2D?

    var totalMeter = 0.0

    var addResetBtn = UIButton()
    var addSaveBtn = UIButton()

    var getLocationBtnState = true
    

    @IBOutlet var mapControlView: RoundedView!

    var timer: Timer = Timer()
    var count: Int = 0



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == " walkHistorySegue" {

            if let destinationVC = segue.destination as? WalkHistoryViewController {

                destinationVC.pickedFinalImage = pickedFinalImage

            }
        }
    }


    @IBAction func getLocationBtn(_ sender: Any) {
        print(#function)
        if getLocationBtnState == true {
            getLocationBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            requestMyLocation()
            addSaveBtn.layer.isHidden = false
            addResetBtn.layer.isHidden = false
            addSaveBtn.addTarget(self, action: #selector(self.saveWalk), for: .touchUpInside)
            addResetBtn.addTarget(self, action: #selector(self.resetWalk), for: .touchUpInside)

            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
            getLocationBtnState = false
        } else if getLocationBtnState == false {
            getLocationBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            getLocationBtnState = true
            addSaveBtn.layer.isHidden = true
            addResetBtn.layer.isHidden = true
            timer.invalidate()
            stopRequestMyLocation()

        }
    }

    @objc func timerCounter() -> Void {
        count += 1
        let time = secondtoHourMinSec(seconds: count)
        let timeString = makeStirng(hours: time.0, minutes: time.1, seconds: time.2)
        timeLabel.text = timeString
    }

    func secondtoHourMinSec(seconds: Int) -> (Int, Int, Int) {
        return ((seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }

    func makeStirng(hours: Int, minutes: Int, seconds: Int) -> String{
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)

        return timeString
    }

    @objc func saveWalk(_ sender: UIButton) {
        print("save btn pressed")
        showAlertController()
    }

    @objc func resetWalk(_ sender: UIButton) {
        print("reset btn pressed")
        if totalMeter != 0 {
            timer.invalidate()
            kmeterLabel.text = "0.0 Km"
            timeLabel.text = "0:0:0"
            totalMeter = 0
            count = 0
            stopRequestMyLocation()
            getLocationBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            getLocationBtnState = true
        } else {
            print("초기화 못합니다")
        }
    }


    func showAlertController() {
        //UIAlertController
        let alert = UIAlertController(title: "산책 기록을 저장합니다", message: "산책을 종료하겠습니까?", preferredStyle: .alert)

        // Button
        //        let realcancel = UIAlertAction(title: "산책 기록이 없어서 저장 못합니다", style: .destructive)
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            guard let data = self.pickedFinalImage?.pngData() else { return }
            if let timeString = self.timeLabel.text {
                CoreDataManager.shared.addNewWalk(cuurentDate: Date(), totalDistance: self.totalMeter, totalTime: timeString, profile: data)
            }


            self.kmeterLabel.text = "0.0 Km"
            self.timeLabel.text = "0:0:0"
            self.totalMeter = 0
            self.count = 0
            self.timer.invalidate()
            self.stopRequestMyLocation()
            self.getLocationBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            self.getLocationBtnState = true


        }
        let cancel = UIAlertAction(title: "취소", style: .destructive, handler: nil)


        alert.addAction(cancel)
        alert.addAction(ok)


        //present
        present(alert, animated: true, completion: nil)
    }

    func getSaveResetBtn() {

        addSaveBtn.setImage(UIImage(systemName: "arrow.down.doc.fill"), for: .normal)
        addSaveBtn.backgroundColor = .systemOrange
        addSaveBtn.tintColor = .white
        addSaveBtn.translatesAutoresizingMaskIntoConstraints = false
        addSaveBtn.layer.cornerRadius = playBtnView.cornerRadius
        view.addSubview(addSaveBtn)

        addSaveBtn.widthAnchor.constraint(equalToConstant: playBtnView.frame.width).isActive = true
        addSaveBtn.heightAnchor.constraint(equalToConstant: playBtnView.frame.height).isActive = true
        addSaveBtn.trailingAnchor.constraint(equalTo: playBtnView.leadingAnchor, constant: -20).isActive = true
        addSaveBtn.bottomAnchor.constraint(equalTo: playBtnView.bottomAnchor, constant: 0).isActive = true

        addResetBtn.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        addResetBtn.backgroundColor = .systemRed
        addResetBtn.tintColor = .white
        addResetBtn.translatesAutoresizingMaskIntoConstraints = false
        addResetBtn.layer.cornerRadius = playBtnView.cornerRadius
        view.addSubview(addResetBtn)

        addResetBtn.widthAnchor.constraint(equalToConstant: playBtnView.frame.width).isActive = true
        addResetBtn.heightAnchor.constraint(equalToConstant: playBtnView.frame.height).isActive = true
        addResetBtn.leadingAnchor.constraint(equalTo: playBtnView.trailingAnchor, constant: 20).isActive = true
        addResetBtn.bottomAnchor.constraint(equalTo: playBtnView.bottomAnchor, constant: 0).isActive = true
    }

    func shadow(inputView: UIView) {
        inputView.layer.shadowColor = UIColor.lightGray.cgColor
        inputView.layer.shadowOpacity = 1
        inputView.layer.shadowRadius = 2
        inputView.layer.shadowOffset = CGSize(width: 5, height: 5)
        inputView.layer.shadowPath = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        self.navigationController?.navigationBar.tintColor = .orange

        shadow(inputView: mapControlView)

        getSaveResetBtn()
        addSaveBtn.layer.isHidden = true
        addResetBtn.layer.isHidden = true

        CoreDataManager.shared.fetchProfile()

        mapGradientView.setGradient(color1: UIColor.systemOrange, color2: UIColor.white, color3: UIColor.white)

        let heigh = self.tabBarController?.tabBar.frame.height ?? 0
        self.tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.maxY - heigh)
        kmeterLabel.layer.cornerRadius = 15
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        locationManager.delegate = self
        locationManager.distanceFilter = 1
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .other
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("사용 불가능")
        case .authorizedWhenInUse, .authorizedAlways:
            print("사용 가능")
            
        }

        guard let loaclValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }

        let region = MKCoordinateRegion(center: loaclValue, latitudinalMeters: 100, longitudinalMeters: 100)
        mapView.setRegion(region, animated: true)

        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }




}

extension MapViewController: CLLocationManagerDelegate {

    func requestMyLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopRequestMyLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate?.locationManagerDidPauseLocationUpdates!(locationManager)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .denied, .restricted:
            print("사용할 수 없음")
            
        case .authorizedWhenInUse, .authorizedAlways:
            print("사용할 있음")
            
        default:
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {return}
        let latitude = location.coordinate.latitude
        let longtitude = location.coordinate.longitude

        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)

        mapView.setRegion(region, animated: true)

        if let previousCoordinate = self.previousCoordinate {
            var points: [CLLocationCoordinate2D] = []

            let point1 = CLLocationCoordinate2DMake(previousCoordinate.latitude, previousCoordinate.longitude)
            let point2: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longtitude)
            points.append(point1)
            points.append(point2)
            let lineDraw = MKPolyline(coordinates: points, count:points.count)
            self.mapView.addOverlay(lineDraw)


            totalMeter += Double(location.coordinate.distance(from: previousCoordinate))
        }
        self.previousCoordinate = location.coordinate
        let result = totalMeter / 1000
        kmeterLabel.text = String(format: "%.2f Km", result)
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    }
}

extension MapViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let v = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)

        if pickedFinalImage != nil {
            v.image = UIImage(named: "dogFace")
            v.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

            let icon = pickedFinalImage
            let imgView = UIImageView(image: icon)
            imgView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            imgView.layer.cornerRadius = imgView.frame.width / 8

            v.leftCalloutAccessoryView = imgView
            v.canShowCallout = true
        } else {
            v.image = UIImage(systemName: "plus")
            v.canShowCallout = true
        }

        return v
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        renderer.strokeColor = .orange
        renderer.lineWidth = 5
        
        return renderer
    }
}

extension CLLocationCoordinate2D {
    //distance in meters, as explained in CLLoactionDistance definition
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination = CLLocation(latitude:from.latitude,longitude:from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}








