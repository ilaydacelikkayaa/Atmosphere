import Foundation

class MusicService {
    func searchMusic(term: String, completion: @escaping ([Track]) -> Void) {
        
        // 1. URL Hazırlığı
        guard let encodedTerm = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        let urlString = "https://itunes.apple.com/search?term=\(encodedTerm)&entity=song&limit=20&country=tr" // Limit artırıldı ki filtreleyince elimizde 10 tane kalsın
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        // 2. İnternet İsteği
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }
            
            // Filtreleme işlemini MUTLAKA bu süslü parantezlerin içinde yapmalısın!
            // ... dataTask içindeki do bloğu ...
            do {
                let itunesResult = try JSONDecoder().decode(iTunesResponse.self, from: data)
                let allTracks = itunesResult.results
                
                var uniqueTracks = [Track]()
                var seenNames = Set<String>()

                for track in allTracks {
                    // trackName zaten String olduğu için doğrudan kullanabiliriz
                    let name = track.trackName.lowercased()
                    
                    if !seenNames.contains(name) {
                        uniqueTracks.append(track)
                        seenNames.insert(name)
                    }
                    
                    if uniqueTracks.count >= 10 { break }
                }
                
                completion(uniqueTracks) // Filtrelenmiş 10 şarkıyı döndür
            } catch {
                print("Çeviri Hatası: \(error)")
                completion([])
            }
            // ...
        }.resume() // Görevi başlatan o meşhur komut
    }
}
