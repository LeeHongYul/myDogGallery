//
//  WeatherDataApi.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/21.
//

import Foundation
import Moya
//"https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=153ecc2a0d1adc1ba46cc2bbde5081ec&units=metric&lang=kr"
enum WeatherDataApi {
    case weatherDataList(q: String, unit: String, lang: String)
}

extension WeatherDataApi: TargetType {
    var baseURL: URL {
        URL(string: "https://api.openweathermap.org")!
    }
    
    var path: String {
        switch self {
        case .weatherDataList:
            return "/data/2.5/weather"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .weatherDataList:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .weatherDataList(q, unit, lang):
            return .requestParameters(parameters: ["q": q, "appid": "153ecc2a0d1adc1ba46cc2bbde5081ec", "unit": unit, "lang": lang ], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
    
    
}


