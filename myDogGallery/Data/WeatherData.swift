//
//  WeatherData.swift
//  myDogGallery
//
//  Created by 이홍렬 on 2023/04/19.
//

import Foundation

struct Forcast: Codable {
    let main: ForcastTemp
    let weather: [ForcastDetail]
    
    struct ForcastTemp: Codable {
        let temp: Double
        let temp_max: Double
        let temp_min: Double
    }
    
    struct ForcastDetail: Codable {
        let id: Int
        let icon: String?
    }
}

struct Air: Codable {
    
    let response: Response
    
    struct Response: Codable {
        let body: Body
    }
    
    struct Body: Codable {
        let totalCount: Int
        let items: [Detail]
        let pageNo, numOfRows: Int
    }
    
    struct Detail: Codable {
        let informOverall: String
    }
 
}
