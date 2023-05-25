//
//  MapDetailViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/05/21.
//

import UIKit
import MapKit
import CoreLocation

class MapDetailViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var detailImage: UIImageView!
    @IBOutlet var detailName: UILabel!
    @IBOutlet var detailDistance: UILabel!
    @IBOutlet var detailTime: UILabel!
    
    var walkDetailImage: UIImage?
    var walkDetail: Double?
    var walkDistance: String?
    
    var fristLat: Double?
    var fristLon: Double?
    var secondLat: Double?
    var secondLon: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.layer.cornerRadius = 15
        detailImage.image = walkDetailImage
        let walkDeatilFormat = (walkDetail! / 1000)
        detailDistance.text = String(format: "%.2f Km", walkDeatilFormat)
        
        detailTime.text = walkDistance
        
        let start = CLLocation(latitude: fristLat!, longitude: fristLon!)
        let end = CLLocation(latitude: secondLat!, longitude: secondLon!)
        
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
    
    func addPin(at coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = title
        pin.subtitle = subtitle
        
        mapView.addAnnotation(pin)
    }
    
}

extension MapDetailViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        
        renderer.strokeColor = .blue
        renderer.lineWidth = 2
        return renderer
    }
}
