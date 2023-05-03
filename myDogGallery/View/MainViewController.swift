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
    
    @IBOutlet var mainPageControl: UIPageControl!
    @IBOutlet var randomPhraseTextView: UITextView!
    @IBOutlet var weatherView: RoundedView!
    
    @IBOutlet var lastWalkDateLabel: UILabel!
    @IBOutlet var weatherDetailLabel: UILabel!
    @IBOutlet var weatherTempLabel: UILabel!
    
    @IBOutlet var mainWeatherImageView: UIImageView!
    
    @IBOutlet var informOverallLabel: UILabel!
    
    var weatherList = [Forcast.ForcastTemp]()
    
    var airList = [Air.Response]()
    
    var locationManager = CLLocationManager()
    
    @IBOutlet var mainCollectionView: UICollectionView!
    
    @IBOutlet var testView: UIView!
    
    
    @IBAction func pageChaged(_ sender: UIPageControl) {
        
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        
        mainCollectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }
    
    var dateFormatter: DateFormatter = {
        let inputDate = DateFormatter()
        inputDate.dateFormat = "MMM d, yyyy"
        inputDate.locale = Locale(identifier: "en_US_POSIX")
        
        return inputDate
    }()
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CoreDataManager.shared.fetchProfile()
        
        mainPageControl.currentPage = 0
        mainPageControl.numberOfPages = CoreDataManager.shared.profileList.count
        
        
        testView.setGradient(color1: UIColor.systemOrange, color2: UIColor.white)
        
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
        mainCollectionView.layer.borderWidth = 1
        mainCollectionView.layer.borderColor = UIColor.lightGray.cgColor
        mainCollectionView.layer.cornerRadius = 15
        mainCollectionView.collectionViewLayout = conditionalLayout
        mainCollectionView.reloadData()
        
        setLocationManager()
        
        //                fetchAirMoya()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        CoreDataManager.shared.fetchMemo()
        if let inputeDate = CoreDataManager.shared.memoList.first?.inputDate {
            lastWalkDateLabel.text =  dateFormatter.string(from: inputeDate)
        }
        
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
                        let tempStr = String(format: "%.1f",list.main.temp)
                        self.weatherDetailLabel.text = list.weather[0].main
                        self.weatherTempLabel.text = tempStr+"°"
                        
                        let urlStr = "https://openweathermap.org/img/wn/" + (list.weather[0].icon)! + "@2x.png"
                        
                        switch list.weather[0].icon {
                        case "01n":
                            self.mainWeatherImageView.image = UIImage(named: "sun")
                        case "02n","03n", "04n","05n":
                            self.mainWeatherImageView.image = UIImage(named: "fog")
                        case "09n", "10n","11n":
                            self.mainWeatherImageView.image = UIImage(named: "rain")
                        case "13n":
                            self.mainWeatherImageView.image = UIImage(named: "snow")
                        default:
                            print("no image")
                        }
                        
                        //                        self.mainWeatherImageView.sd_setImage(with: URL(string: urlStr))
                        
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
    func setGradient(color1:UIColor, color2:UIColor){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 5.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 5.0, y: 1.0)
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

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        mainPageControl.currentPage = indexPath.row
    }
}

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("위치 업데이트!")
            print("위도 : \(location.coordinate.latitude)")
            print("경도 : \(location.coordinate.longitude)")
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
}



