//
//  Track.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 21.02.2026.
//

import Foundation
struct iTunesResponse: Codable{ // iTunes'dan dönen ana liste paketini karşılar
    let results:[Track]
    
}
struct Track: Codable{ //tek bir şarkının bilgilerini tutan yapı
    let trackName:String //şarkı sözü
    let artistName: String?     // sanatçı adı
    let artworkUrl100:String // albüm kapağının internet adresi
    
}

