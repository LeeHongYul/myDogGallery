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
    var timer: Timer = Timer()
    var count: Int = 0
    var totalMeter = 0.0
    
    var addResetBtn = UIButton()
    var addSaveBtn = UIButton()
    
    var pickedFinalImage: UIImage?
    
    var getLocationBtnState = true
    let locationManager = CLLocationManager()
    var previousCoordinate: CLLocationCoordinate2D?
    var drawPoint: [CLLocationCoordinate2D] = []
    
    @IBOutlet var playBtnView: RoundedView!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var getLocationBtn: UIButton!
    @IBOutlet var kmeterLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var mapControlView: RoundedView!
    //MapViewController에서 산책을 한 프로필의 이미지를 WalkHistoryViewController로 넘기기 위한 코드
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == " walkHistorySegue" {
            
            if let destinationVC = segue.destination as? WalkHistoryViewController {
                
                destinationVC.pickedFinalImage = pickedFinalImage
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .orange
        
        getSaveResetBtn()
        addSaveBtn.layer.isHidden = true
        addResetBtn.layer.isHidden = true
        
        CoreDataManager.shared.fetchProfile()
        
        let tabBarHeight = self.tabBarController?.tabBar.frame.height ?? 0
        self.tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.maxY - tabBarHeight)
        kmeterLabel.layer.cornerRadius = 15
        
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        
        locationManager.delegate = self
        locationManager.distanceFilter = 1
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            print("location 사용 불가능입니다.")
        case .authorizedWhenInUse, .authorizedAlways:
            print("location 사용 가능입니다.")
            
        }
        
        guard let localValue: CLLocationCoordinate2D = locationManager.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(center: localValue, latitudinalMeters: 50, longitudinalMeters: 50)
        
        mapView.setRegion(region, animated: true)
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
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
    
    func makeStirng(hours: Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        
        return timeString
    }
    
    @IBAction func getLocationBtn(_ sender: Any) {
        print(#function)
        if getLocationBtnState == true {
            getLocationBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            getLocationBtnState = false
            requestMyLocation()
            addSaveBtn.layer.isHidden = false
            addResetBtn.layer.isHidden = false
            addSaveBtn.addTarget(self, action: #selector(self.saveWalk), for: .touchUpInside)
            addResetBtn.addTarget(self, action: #selector(self.resetWalk), for: .touchUpInside)
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
            
        } else if getLocationBtnState == false {
            getLocationBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            getLocationBtnState = true
            stopRequestMyLocation()
            addSaveBtn.layer.isHidden = true
            addResetBtn.layer.isHidden = true
            timer.invalidate()
        }
    }
    
    @objc func saveWalk(_ sender: UIButton) {
        print("save btn pressed")
        showAlertController()
    }
    
    @objc func resetWalk(_ sender: UIButton) {
        print("reset btn pressed")
        self.stopRequestMyLocation()
        self.timer.invalidate()
        
        let alert = UIAlertController(title: "산책 기록을 초기화합니다.", message: "산책을 초기화하겠습니까?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            if self.totalMeter != 0 || self.count != 0 {
                self.timer.invalidate()
                self.kmeterLabel.text = "0.0 Km"
                self.timeLabel.text = "00:00:00"
                self.totalMeter = 0
                self.count = 0
                self.drawPoint = []
                self.stopRequestMyLocation()
                self.getLocationBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
                self.getLocationBtnState = true
            } else {
                print("초기화 못합니다")
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .destructive) { _ in
            self.requestMyLocation()
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerCounter), userInfo: nil, repeats: true)
        }
        
        alert.addAction(cancel)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showAlertController() {
        let alert = UIAlertController(title: "산책 기록을 저장합니다.", message: "산책을 종료하겠습니까?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default) { _ in
            guard let data = self.pickedFinalImage?.pngData() else { return }
            if let timeString = self.timeLabel.text {
                CoreDataManager.shared.addNewWalk(cuurentDate: Date(), totalDistance: self.totalMeter, totalTime: timeString, profile: data, startLon: self.drawPoint.first?.longitude ?? 0.0, startLat: self.drawPoint.first?.latitude ?? 0.0, endLon: self.drawPoint.last?.longitude ?? 0.0, endLat: self.drawPoint.last?.latitude ?? 0.0)
                self.drawPoint = []
            }
            
            self.kmeterLabel.text = "0.0 Km"
            self.timeLabel.text = "00:00:00"
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
        
        present(alert, animated: true, completion: nil)
        addSaveBtn.layer.isHidden = true
        addResetBtn.layer.isHidden = true
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
        
        addResetBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
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
            
            drawPoint.append(point2)
            points.append(point1)
            points.append(point2)
            let lineDraw = MKPolyline(coordinates: points, count: points.count)
            self.mapView.addOverlay(lineDraw)
            
            totalMeter += Double(location.coordinate.distance(from: previousCoordinate))
        }
        print(drawPoint.count)
        self.previousCoordinate = location.coordinate
        let result = totalMeter / 1000
        kmeterLabel.text = String(format: "%.2f Km", result)
    }
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reusableAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier, for: annotation)
        
        if pickedFinalImage != nil {
            reusableAnnotation.image = UIImage(named: "dogFace")
            reusableAnnotation.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            
            let icon = pickedFinalImage
            let imgView = UIImageView(image: icon)
            imgView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            imgView.layer.cornerRadius = imgView.frame.width / 8
            
            reusableAnnotation.leftCalloutAccessoryView = imgView
            reusableAnnotation.canShowCallout = true
        } else {
            reusableAnnotation.image = UIImage(systemName: "plus")
            reusableAnnotation.canShowCallout = true
        }
        
        return reusableAnnotation
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .orange
        renderer.lineWidth = 5
        return renderer
    }
}

extension CLLocationCoordinate2D {
    func distance(from: CLLocationCoordinate2D) -> CLLocationDistance {
        let destination = CLLocation(latitude: from.latitude, longitude: from.longitude)
        return CLLocation(latitude: latitude, longitude: longitude).distance(from: destination)
    }
}
