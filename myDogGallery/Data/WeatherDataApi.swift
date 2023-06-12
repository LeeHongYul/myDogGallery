//
//  WeatherDataApi.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/21.
//

import Foundation
import Moya


enum WeatherDataApi {
    case weatherDataList(lat: Double, lon: Double, units: String)
}

extension WeatherDataApi: TargetType {
    var baseURL: URL {
        let urlString = "https://api.openweathermap.org"
        return URL(string: urlString) != nil ? URL(string: urlString)! : URL(fileURLWithPath: "")
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
        case let .weatherDataList(lat, lon, units):
            return .requestParameters(parameters: ["lat": lat, "lon": lon, "units": units, "appid": "153ecc2a0d1adc1ba46cc2bbde5081ec"], encoding: URLEncoding.queryString)
        }
    }
    var headers: [String: String]? {
        nil
    }
}
