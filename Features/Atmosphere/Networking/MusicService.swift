//
//  MusicService.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 21.02.2026.
//

import Foundation

class MusicService {
    func searchMusic(term: String, completion: @escaping ([Track]) -> Void) {
        
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "https://itunes.apple.com/search?term=\(encodedTerm)&entity=song&limit=10"
        
        guard let url = URL(string: urlString) else {
            completion([]) // URL hatalıysa boş liste dön
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            // Veri gelmiş mi ve hata yok mu kontrol et
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            do {
                let itunesResult = try JSONDecoder().decode(iTunesResponse.self, from: data)
                    completion(itunesResult.results)
            } catch {
                print("Çeviri Hatası: \(error)")
                completion([])
            }
        }.resume() 
    }
}
