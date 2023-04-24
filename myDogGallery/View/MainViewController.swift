//
//  ViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit
import Moya
import CoreLocation


class MainViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var testView: UIView!
    @IBOutlet var weatherTempLabel: UILabel!
    
    @IBOutlet var informOverallLabel: UILabel!
    
    var weatherList = [Forcast.ForcastTemp]()
    var airList = [Air.Response]()
    var locationManager = CLLocationManager()
    
    @IBOutlet var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.fetchProfile()
        
        testView.setGradient(color1: UIColor.white, color2: UIColor.systemOrange, color3: UIColor.orange)
        
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
        
        //        fetchAirMoya()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("위치 업데이트!")
            print("위도 : \(location.coordinate.latitude)")
            print("경도 : \(location.coordinate.longitude)")
        }
    }
        
    // 위치 가져오기 실패
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    
    
    
    
    //    func fetchAirMoya() {
    //        let provider = MoyaProvider<AirDataApi>()
    //        provider.request(.airDataList) { result in
    //            switch result {
    //            case let .success(moyaResponse):
    //                let data = moyaResponse.data
    //                let statusCode = moyaResponse.statusCode
    //                print(moyaResponse.statusCode)
    //
    //                do {
    //                    try moyaResponse.filterSuccessfulStatusCodes()
    //
    //                    let decoder = JSONDecoder()
    //                    let list = try decoder.decode(Air.self, from: data)
    //
    //                    self.airList = [list.response]
    //                    DispatchQueue.main.async {
    //                        print(list.response.body.items)
    //                    }
    //                } catch {
    //                    print(error)
    //                }
    //
    //            case let .failure(error):
    //                break
    //            }
    //        }
    //    }
    
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
                        //                        if list.main.temp_min < 20 {
                        //                            self.weatherTempLabel.text = "산책하기 좋은 날씨입니다"
                        //                        } else {
                        //                            self.weatherTempLabel.text = "산책하기 적합한 날씨는 아니네요"
                        //                        }
                    }
                } catch {
                    print(error)
                }
                
            case let .failure(error):
                break
            }
        }
    }
    //    func fetch(cityName: String) {
    //        let urlStr = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=153ecc2a0d1adc1ba46cc2bbde5081ec&units=metric&lang=kr"
    //        let url = URL(string: urlStr)
    //        guard let url else { return }
    //        let urlRequest = URLRequest(url: url)
    //
    //        let session = URLSession(configuration: .default)
    //        session.dataTask(with: urlRequest) { data, response, error in
    //            if let error = error { return }
    //
    //            guard let httpResponse = response as? HTTPURLResponse else { return }
    //
    //            guard httpResponse.statusCode == 200 else { return }
    //
    //            guard let data = data else { return }
    //
    //            let nf = NumberFormatter()
    //
    //            let decoder = JSONDecoder()
    //
    //            do {
    //                let list = try decoder.decode(Forcast.self, from: data)
    //                self.weatherList = [list.main]
    //                DispatchQueue.main.async {
    //                    if list.main.temp_min < 20 {
    //                        self.weatherTempLabel.text = "산책하기 좋은 날씨입니다"
    //                    } else {
    //                        self.weatherTempLabel.text = "산책하기 적합한 날씨는 아니네요"
    //                    }
    //                    print(#function ,list.main.temp)
    //                }
    //            } catch {
    //                print(error)
    //            }
    //        }.resume()
    //    }
    
    
    
    
    
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


