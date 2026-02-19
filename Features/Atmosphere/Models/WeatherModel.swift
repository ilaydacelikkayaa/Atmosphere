//
//  WeatherModel.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 18.02.2026.
//
import Foundation

struct WeatherResponse:Codable{
    let main: MainStats
    let weather: [WeatherDescription]
    let name: String
}
struct MainStats: Codable {
    let temp: Double
}
struct WeatherDescription: Codable {
    let main: String
    let description: String

}
