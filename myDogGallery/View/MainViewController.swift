//
//  ViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit
import Moya
import CoreLocation
import SDWebImage


class MainViewController: UIViewController {
    
    @IBOutlet var randomPhraseTextView: UITextView!
    @IBOutlet var weatherView: RoundedView!
    
    @IBOutlet var weatherTempLabel: UILabel!
    
    @IBOutlet var mainWeatherImageView: UIImageView!
    
    @IBOutlet var informOverallLabel: UILabel!
    
    var weatherList = [Forcast.ForcastTemp]()

    var airList = [Air.Response]()
    
    var locationManager = CLLocationManager()
    
    @IBOutlet var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.fetchProfile()
        
//        weatherView.setGradient(color1: UIColor.white, color2: UIColor.systemOrange, color3: UIColor.orange)
        
        fetchMoya()
        
        let conditionalLayout = UICollectionViewCompositionalLayout { sectionIndex, env in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 15)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
            
        }
        
        mainCollectionView.layer.cornerRadius = 15
        mainCollectionView.collectionViewLayout = conditionalLayout
        mainCollectionView.reloadData()
        
        setLocationManager()
        
//                fetchAirMoya()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        randomPhraseTextView.text = "\(phraselist[Int.random(in: 0 ... phraselist.count - 1)])"
        
        CoreDataManager.shared.fetchProfile()
        mainCollectionView.reloadData()
    }
    
    func setLocationManager() {
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            }
            else {
                print("위치 서비스 허용 off")
            }
        }
    }
    
    
    
    
    
    
    
//        func fetchAirMoya() {
//            let provider = MoyaProvider<AirDataApi>()
//            provider.request(.airDataList) { result in
//                switch result {
//                case let .success(moyaResponse):
//                    let data = moyaResponse.data
//                    let statusCode = moyaResponse.statusCode
//                    print(moyaResponse.statusCode)
//
//                    do {
//                        try moyaResponse.filterSuccessfulStatusCodes()
//
//                        let decoder = JSONDecoder()
//                        let list = try decoder.decode(Air.self, from: data)
//
//                        self.airList = [list.response]
//                        DispatchQueue.main.async {
//                            print(list.response.body.items[0].informOverall)
//                        }
//                    } catch {
//                        print(error)
//                    }
//
//                case let .failure(error):
//                    break
//                }
//            }
//        }
    
    func fetchMoya() {
        let provider = MoyaProvider<WeatherDataApi>()
        provider.request(.weatherDataList(lat: locationManager.location?.coordinate.latitude ?? 0, lon: locationManager.location?.coordinate.longitude ?? 0, units: "metric")) { result in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                let statusCode = moyaResponse.statusCode
                
                do {
                    try moyaResponse.filterSuccessfulStatusCodes()
                    
                    let decoder = JSONDecoder()
                    let list = try decoder.decode(Forcast.self, from: data)
                    
                    self.weatherList = [list.main]
                    
                    DispatchQueue.main.async {
                        self.weatherTempLabel.text = "\(list.main.temp)"
                       
                        let urlStr = "https://openweathermap.org/img/wn/" + (list.weather[0].icon)! + "@2x.png"
                            
                        self.mainWeatherImageView.sd_setImage(with: URL(string: urlStr))

                    }
                } catch {
                    print(error)
                }
                
            case let .failure(error):
                break
            }
        }
    }
}

extension UIView{
    func setGradient(color1:UIColor, color2:UIColor, color3:UIColor){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        gradient.locations = [0.0 , 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = bounds
        gradient.type = .axial
        gradient.cornerRadius = 15
        layer.addSublayer(gradient)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(CoreDataManager.shared.profileList.count)
        return CoreDataManager.shared.profileList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as! MainCollectionViewCell
        
        let target = CoreDataManager.shared.profileList[indexPath.row]
        
        cell.mainCollectionLabel.text = target.name
        cell.mainImageView.image = UIImage(data: target.image!)
        
        return cell
    }
}

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("위치 업데이트!")
            print("위도 : \(location.coordinate.latitude)")
            print("경도 : \(location.coordinate.longitude)")
        }
    }
        
   
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
}


