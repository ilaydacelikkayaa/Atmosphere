import Foundation

class AIService {
    private let apiKey = Secrets.geminiApiKey
    private let baseUrl = "https://generativelanguage.googleapis.com"

    func generateMusicQuery(weather: String, userInput: String, completion: @escaping (String?) -> Void) {
        
        print(" Uygun model aranıyor...")
        let listModelsUrl = URL(string: "\(baseUrl)/v1beta/models?key=\(apiKey)")!
        
        URLSession.shared.dataTask(with: listModelsUrl) { [weak self] data, response, error in
            guard let self = self, let data = data else {
                completion(nil)
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let models = json?["models"] as? [[String: Any]] ?? []
            
            // İçerik üretebilen ilk 'gemini' modelini seç
            let activeModel = models.first { model in
                let name = model["name"] as? String ?? ""
                let methods = model["supportedGenerationMethods"] as? [String] ?? []
                return name.contains("gemini") && methods.contains("generateContent")
            }
            
            let modelPath = activeModel?["name"] as? String ?? "models/gemini-1.5-flash"
            print("Seçilen Aktif Model: \(modelPath)")
            
            self.sendRequest(to: modelPath, weather: weather, userInput: userInput, completion: completion)
            
        }.resume()
    }
    
    private func sendRequest(to modelPath: String, weather: String, userInput: String, completion: @escaping (String?) -> Void) {
        let urlString = "\(baseUrl)/v1beta/\(modelPath):generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else { completion(nil); return }
        
        let prompt = """
        Hava durumu: \(weather), Kullanıcı Aktivitesi: \(userInput). 
        Sen bir müzik küratörüsün. Bu atmosfere uygun bir çalma listesi hazırlaman gerekiyor. 
        Bana şu formatta cevap ver:
        Arama Terimi | Açıklama

        Arama Terimi: iTunes'da aratıldığında 10-20 farklı popüler Türkçe şarkı döndürecek genel bir müzik tarzı olsun. (Örn: 'Popüler Türkçe Rock', '90lar Türkçe Pop', 'Yeni Nesil Alternatif Türkçe')
        Açıklama: Kullanıcıya bu listeyi neden hazırladığını anlatan samimi bir cümle.

        Örnek Çıktı: 90lar Türkçe Pop | Bugün hava biraz kapalı ama bu nostaljik şarkılarla enerjini yükseltip harika bir temizlik yapabilirsin!
        """
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]]
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { completion(nil); return }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Google Cevabı: \(jsonString)")
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let candidates = json["candidates"] as? [[String: Any]],
               let content = candidates.first?["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let text = parts.first?["text"] as? String {
                
                completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
            } else {
                completion(nil)
            }
        }.resume()
    }
}
