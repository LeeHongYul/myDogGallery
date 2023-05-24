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

    var weatherList = [Forcast.ForcastTemp]()

    var locationManager = CLLocationManager()

    @IBOutlet var mainGradientView: UIView!

    @IBOutlet var weatherView: RoundedView!
    @IBOutlet var mainWeatherImageView: UIImageView!
    @IBOutlet var weatherTempLabel: UILabel!
    @IBOutlet var weatherDetailLabel: UILabel!

    @IBOutlet var phaseView: RoundedView!
    @IBOutlet var randomPhraseTextView: UITextView!

    @IBOutlet var walkHistoryView: RoundedView!
    @IBOutlet var lastWalkDateLabel: UILabel!

    @IBOutlet var mainProfileView: UIView!
    @IBOutlet var mainCollectionView: UICollectionView!

    @IBOutlet var mainPageControl: UIPageControl!

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

    /// 날씨를 나타내는 뷰에 그림자 넣는 코드
    /// - Parameter inputView: 그림자를 넣을 뷰
    func shadowWeather(inputView: UIView) {
        inputView.layer.shadowColor = UIColor.black.cgColor
        inputView.layer.shadowOpacity = 0.9
        inputView.layer.shadowRadius = 10
        inputView.layer.shadowOffset = CGSize(width: 0, height: 1)
        inputView.layer.shadowPath = nil
    }

    /// 날씨 API  데이터를 Moya를 통하여 가져오는 코드
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
                        let tempStr = String(format: "%.1f", list.main.temp)
                        self.weatherDetailLabel.text = list.weather[0].main
                        self.weatherTempLabel.text = tempStr+"°"

                        switch list.weather[0].icon {
                        case "01n", "01d":
                            self.mainWeatherImageView.image = UIImage(named: "sun")
                        case "02n", "03n", "04n", "05n", "02d", "03d", "04d", "05d", "50n", "50d":
                            self.mainWeatherImageView.image = UIImage(named: "fog")
                        case "09n", "10n", "11n", "09d", "10d", "11d":
                            self.mainWeatherImageView.image = UIImage(named: "rain")
                        case "13n", "13d":
                            self.mainWeatherImageView.image = UIImage(named: "snow")
                        default:
                            print("no image")
                        }
                    }
                } catch {
                    print(error)
                }

            case let .failure(_):
                break
            }
        }
    }

    func setLocationManager() {
        locationManager.delegate = self

        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.requestWhenInUseAuthorization()
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startUpdatingLocation()
            } else {
                print("위치 서비스 허용 off")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mainGradientView.setGradient(color1: UIColor.systemOrange, color2: UIColor.white, color3: UIColor.white)

        shadowWeather(inputView: weatherView)

        fetchMoya()

        CoreDataManager.shared.fetchProfile()
        print(CoreDataManager.shared.profileList.count, "프로필 수")
        mainPageControl.currentPage = 0
        mainPageControl.numberOfPages = CoreDataManager.shared.profileList.count

        let conditionalLayout = UICollectionViewCompositionalLayout { sectionIndex, env in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            section.orthogonalScrollingBehavior = .groupPaging
            return section
        }

        mainCollectionView.layer.cornerRadius = 15
        mainCollectionView.collectionViewLayout = conditionalLayout
        mainCollectionView.reloadData()
        setLocationManager()
    }

    /// viewWillAppear 실행될 때마다 추가된 프로필 이미지, 페이지 컨트롤, 최근 산책 날짜, 글귀 정보 추가한다.
    /// - Parameter animated: <#animated description#>
    override func viewWillAppear(_ animated: Bool) {
        if CoreDataManager.shared.profileList.count != 0 {
            mainProfileView.isHidden = true
        } else {
            mainProfileView.isHidden = false
        }
        CoreDataManager.shared.fetchProfile()

        mainPageControl.currentPage = 0
        mainPageControl.numberOfPages = CoreDataManager.shared.profileList.count

        CoreDataManager.shared.fetchMemo()
        if let inputeDate = CoreDataManager.shared.memoList.first?.inputDate {
            lastWalkDateLabel.text =  dateFormatter.string(from: inputeDate)
        }
        randomPhraseTextView.text = "\(phraselist[Int.random(in: 0 ... phraselist.count - 1)])"
        mainCollectionView.reloadData()
    }
}

extension UIView {

    /// 그라데이션을 만들기 위한 함수
    /// - Parameters:
    ///   - color1: 그라데이션에 들어갈 color1
    ///   - color2: 그라데이션에 들어갈 color2
    ///   - color3: 그라데이션에 들어갈 color3
    func setGradient(color1: UIColor, color2: UIColor, color3: UIColor) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        gradient.locations = [0.0, 0.8]
        gradient.startPoint = CGPoint(x: 5.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 5.0, y: 1.0)
        gradient.frame = bounds
        gradient.type = .axial

        layer.addSublayer(gradient)
    }
}

extension MainViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("위치 업데이트")
            print("위도 : \(location.coordinate.latitude)")
            print("경도 : \(location.coordinate.longitude)")

            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
}

extension MainViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CoreDataManager.shared.profileList.count
    }

    /// CoreData로 등록된 프로필의 이미지 가져오는 코드
    /// - Parameters:
    ///   - collectionView: <#collectionView description#>
    ///   - indexPath: <#indexPath description#>
    /// - Returns: <#description#>
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCell", for: indexPath) as! MainCollectionViewCell
        let target = CoreDataManager.shared.profileList[indexPath.row]

        if let imageData = target.image {
            cell.mainImageView.image = UIImage(data: imageData)
        }
        return cell
    }
}

extension MainViewController: UICollectionViewDelegate {

    /// CollectionView에서 프로필 넘길때 해당되는 indexPath.row가 PageControl의 현재 페이지가 같도록 하는 코드
    /// - Parameters:
    ///   - collectionView: <#collectionView description#>
    ///   - cell: <#cell description#>
    ///   - indexPath: <#indexPath description#>
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        mainPageControl.currentPage = indexPath.row
    }
}
