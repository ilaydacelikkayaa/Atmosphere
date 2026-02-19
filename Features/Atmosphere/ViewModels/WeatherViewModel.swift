import Foundation

class WeatherViewModel {
        var onWeatherUpdate: ((WeatherResponse) -> Void)?
    
    func fetchWeather(for city: String) {
        let apiKey = "4a7fc281429de91ab9c3f27c7c2a18f5"
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("API'den Gelen Ham Veri: \(jsonString)")
                }

                let weather = try JSONDecoder().decode(WeatherResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.onWeatherUpdate?(weather)
                }
            } catch {
                print("Decoding Hatası: \(error)")
            }
        }.resume()
        
    }
    
}
