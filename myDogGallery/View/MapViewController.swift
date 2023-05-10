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
    
    @IBOutlet var mapGradientView: UIView!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var getLocationBtn: UIButton!
    @IBOutlet var kmeterLabel: UILabel!

    let locationManager = CLLocationManager()
    
    var previousCoordinate: CLLocationCoordinate2D?

    var totalMeter = 0.0

    var getLocationBtnState = true
    


    @IBOutlet var testPickerView: UIView!


    @IBOutlet var textImageView: UIImageView!

    @IBOutlet var testTextField: UITextField!


    @IBOutlet var testBar: UIToolbar!





    @IBAction func testDoneBtn(_ sender: Any) {
        testTextField.resignFirstResponder()
    }






    @IBAction func getLocationBtn(_ sender: Any) {
        print(#function)
        if getLocationBtnState == true {
            getLocationBtn.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            requestMyLocation()
            getLocationBtnState = false
        } else if getLocationBtnState == false {
            getLocationBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            getLocationBtnState = true
            stopRequestMyLocation()

        }
    }

    
    @IBAction func restartWalkBtn(_ sender: Any) {
        print(#function)
        print("산책 기록을 초기화합니다")
        print(totalMeter)

        if totalMeter != 0 {
            kmeterLabel.text = "0.0 Km"
            totalMeter = 0
            stopRequestMyLocation()
            getLocationBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
            getLocationBtnState = true
        } else {
            print("초기화 못합니다")
        }
    }

    @IBAction func saveWalkBtn(_ sender: Any) {
        print("산책 기록을 저장합니다")
        print(totalMeter)
        showAlertController()

    }

    func showAlertController() {
            //UIAlertController
            let alert = UIAlertController(title: "산책 기록 저장", message: "산책이 다 끝났나요?", preferredStyle: .alert)

            // Button
        let realcancel = UIAlertAction(title: "산책 기록이 없어서 저장 못합니다", style: .destructive)
        let ok = UIAlertAction(title: "확인", style: .default) { _ in

                self.kmeterLabel.text = "0.0 Km"
                CoreDataManager.shared.addNewWalk(cuurentDate: Date(), totalDistance: self.totalMeter)
                self.totalMeter = 0
                self.stopRequestMyLocation()
                self.getLocationBtnState = true


        }
            let cancel = UIAlertAction(title: "취소", style: .destructive, handler: nil)


            alert.addAction(cancel)
            alert.addAction(ok)


            //present
            present(alert, animated: true, completion: nil)
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.fetchProfile()
        testTextField.inputView = testPickerView
        testTextField.inputAccessoryView = testBar
        textImageView.layer.cornerRadius = textImageView.frame.width / 2
        textImageView.layer.borderWidth = 1
        textImageView.layer.borderColor = UIColor.systemOrange.cgColor


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
        
        
        
        func addPin(at coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
            
            let pin = MKPointAnnotation()
            pin.coordinate = coordinate
            pin.title = title
            pin.subtitle = subtitle
            
            mapView.addAnnotation(pin)
        }
        
        
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func requestMyLocation() {
        
        locationManager.startUpdatingLocation()
        
    }
    
    func stopRequestMyLocation() {
        locationManager.stopUpdatingLocation()
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

extension MapViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        CoreDataManager.shared.profileList.count
    }


}

extension MapViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {

        let target = CoreDataManager.shared.profileList[row]
        return target.name
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let target = CoreDataManager.shared.profileList[row]
        testTextField.text = target.name

        let dataImage = UIImage(data: target.image!)
        textImageView.image = dataImage
    }


}



