//
//  AtmosphereSnapshot.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 26.02.2026.
//

import Foundation

struct AtmosphereSnapshot:Codable{
    let date: Date
    let weather: String
    let note: String
    let songName: String
    let artistName: String
}
