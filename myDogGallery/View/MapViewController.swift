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
    
    @IBAction func getLocationBtn(_ sender: UIButton) {

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
        print("산책 기록을 초기화합니다")
        print(totalMeter)
        kmeterLabel.text = "0.0 Km"
        totalMeter = 0
        stopRequestMyLocation()
        getLocationBtnState = true

    }

    @IBAction func saveWalkBtn(_ sender: Any) {
        print("산책 기록을 저장합니다")
        print(totalMeter)
        kmeterLabel.text = "0.0 Km"
        CoreDataManager.shared.addNewWalk(cuurentDate: Date(), totalDistance: totalMeter)
        totalMeter = 0
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

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





