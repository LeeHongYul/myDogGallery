//
//  MapDetailViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/21.
//

import UIKit
import MapKit
import CoreLocation

class MapDetailViewController: BaseViewController {

    var walkHistory: WalkEntity?

    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var detailImage: UIImageView!
    @IBOutlet var detailDistance: UILabel!
    @IBOutlet var detailTime: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.layer.cornerRadius = 15

        if let target = walkHistory {
            detailImage.image = UIImage(data: target.profile!)

            let walkDeatilFormat = (target.totalDistance / 1000)
            detailDistance.text = String(format: "%.2f Km", walkDeatilFormat)

            detailTime.text = target.totalTime

            let start = CLLocation(latitude: target.startLat, longitude: target.startLon)
            let end = CLLocation(latitude: target.endLat, longitude: target.endLon)

            addPin(at: start.coordinate, title: "출발")
            addPin(at: end.coordinate, title: "도착")

            let request = MKDirections.Request()

            let startPlacemark = MKPlacemark(coordinate: start.coordinate)
            let endPlacemark = MKPlacemark(coordinate: end.coordinate)

            request.source = MKMapItem(placemark: startPlacemark)
            request.destination = MKMapItem(placemark: endPlacemark)

            request.transportType = .walking

            request.requestsAlternateRoutes = true

            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                if let error {
                    print(error)
                    return
                }

                if let response {
                    for route in response.routes {

                        self.mapView.addOverlay(route.polyline)
                        self.mapView.setVisibleMapRect(route.polyline.boundingMapRect.insetBy(dx: -1000, dy: -1000), animated: true)
                    }
                }
            }
        }
    }

    /// Annotation 생성 및 출발, 도착점 title 설정
    func addPin(at coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = title
        pin.subtitle = subtitle
        
        mapView.addAnnotation(pin)
    }
    
}

// 산책한 경로 색 지정
extension MapDetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        renderer.strokeColor = .systemOrange
        renderer.lineWidth = 3
        return renderer
    }
}
