//
//  WeatherDataApi.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/21.
//

import Foundation
import Moya


enum AirDataApi {
    case airDataList
}

extension AirDataApi: TargetType {
    var baseURL: URL {
        URL(string: "https://apis.data.go.kr")!
    }

    var path: String {
        switch self {
        case .airDataList:
            return "/B552584/ArpltnInforInqireSvc/getMinuDustFrcstDspth"
        }
    }

    var method: Moya.Method {
        switch self {
        case .airDataList:
            return .get
        }
    }
    var task: Moya.Task {
        switch self {
        case .airDataList:
            return .requestParameters(parameters: [
                "serviceKey": "xpJQ7oTQFvmMZUv%2BlfRVof8rIRxQ0p6wL3rwtMQjXFxcRuThGaiZagr4bSJR76KMpd8GeFdnF3mxA%2BNXjyOV0Q%3D%3D",
                "returnType": "json",
                "searchDate": "2023-04-14",
                "InformCode": "PM10"], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String : String]? {
       nil
    }


}





enum WeatherDataApi {
    case weatherDataList(lat: Double, lon: Double, units: String)
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
        case let .weatherDataList(lat, lon, units):
            return .requestParameters(parameters: ["lat": lat, "lon": lon, "units": units, "appid": "153ecc2a0d1adc1ba46cc2bbde5081ec"], encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        nil
    }
    
    
}


