//
//  ViewController.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet var weatherTempLabel: UILabel!
    
    let apiKey = "153ecc2a0d1adc1ba46cc2bbde5081ec"
    
    var weatherList = [Forcast.ForcastTemp]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch(cityName: "seoul")
    }
    
    func fetch(cityName: String) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=153ecc2a0d1adc1ba46cc2bbde5081ec&units=metric&lang=kr"
        let url = URL(string: urlStr)
        guard let url else { return }
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error { return }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            guard httpResponse.statusCode == 200 else { return }
            
            guard let data = data else { return }
            
            let nf = NumberFormatter()
            
            let decoder = JSONDecoder()
            
            do {
                let list = try decoder.decode(Forcast.self, from: data)
                self.weatherList = [list.main]
                DispatchQueue.main.async {
                    if list.main.temp_min < 20 {
                        self.weatherTempLabel.text = "산책하기 좋은 날씨입니다"
                    } else {
                        self.weatherTempLabel.text = "산책하기 적합한 날씨는 아니네요"
                    }
                    print(#function ,list.main.temp)
                }
            } catch {
                print(error)
            }
        }.resume()
        
    }
}

