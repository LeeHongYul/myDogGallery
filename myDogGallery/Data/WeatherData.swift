//
//  WeatherData.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import Foundation

struct Forcast: Codable {

    enum CodingKeys: String, CodingKey {
        case mainForcast = "main"
        case weather = "weather"
    }

    let mainForcast: ForcastTemp
    let weather: [ForcastDetail]
    
    struct ForcastTemp: Codable {

        enum CodingKeys: String, CodingKey {
            case mainTempature = "temp"
            case maxTempature = "temp_max"
            case minTempature = "temp_min"
        }

        let mainTempature: Double
        let maxTempature: Double
        let minTempature: Double
    }
    struct ForcastDetail: Codable {
        let main: String
        let id: Int
        let icon: String?
    }
}
