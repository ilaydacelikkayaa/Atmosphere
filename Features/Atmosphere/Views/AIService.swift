//
//  AIService.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 19.02.2026.
//

import Foundation

class AIService{
    private let apiKey = Secrets.geminiApiKey
    func generateMusicQuery(weather: String,
                            userInput: String,
                            completion: @escaping (String?) -> Void){ //completion asenkron oldugu icin beklemeyi saglar
        let prompt = "Hava: \(weather), Amaç: \(userInput)"
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=\(Secrets.geminiApiKey)"
        guard let url = URL(string: urlString) else {
                 completion(nil)
                 return
             }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") //etiketi
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data else {
                completion(nil)
                return
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
