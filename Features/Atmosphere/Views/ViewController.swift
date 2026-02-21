//
//  ViewController.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 18.02.2026.
//

import UIKit

class ViewController: UIViewController {

    let viewModel = WeatherViewModel()
    private var currentWeather: WeatherResponse?
    let aiService = AIService()
    private let label: UILabel = {
            let l = UILabel()
            l.numberOfLines = 0
            l.textAlignment = .center
            l.font = .systemFont(ofSize: 26, weight: .bold)
            l.text = "Hava Durumu Yükleniyor..."
            l.translatesAutoresizingMaskIntoConstraints = false
            return l
        }()
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .systemOrange
        return iv
    }()
    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Ne yapmak istiyorsun?"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Find My Atmosphere", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            setupUI()
            setupBindings()
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)


            viewModel.fetchWeather(for: "Isparta")
        }
    @objc private func buttonTapped() {
        guard let userInput = textField.text, !userInput.isEmpty,
              let weatherInfo = label.text else { return }
        
        print("AI'ya soruluyor...")
        
        aiService.generateMusicQuery(weather: weatherInfo, userInput: userInput) { [weak self] musicQuery in
            
            DispatchQueue.main.async {
                if let query = musicQuery {
                    print("AI Önerisi: \(query)")
                    self?.label.text = "Senin için önerim:\n\(query)"
                } else {
                    self?.label.text = "AI şu an meşgul, tekrar dene."
                }
            }
        }
    }
    
    private func getWeatherStyle(for condition: String) -> (symbolName: String, color: UIColor) {
        switch condition {
        case "Clear":
            return ("sun.max.fill", .systemYellow)
        case "Clouds":
            return ("cloud.fill", .systemGray)
        case "Rain":
            return ("cloud.rain.fill", .systemBlue)
        case "Snow":
            return ("snow", .systemCyan)
        default:
            return ("cloud.sun.fill", .systemGray) 
        }
    }
    
    private func setupUI() {
            view.addSubview(label)
            view.addSubview(iconImageView)
            view.addSubview(textField)
            view.addSubview(actionButton)
            NSLayoutConstraint.activate([
                iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
                iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                iconImageView.widthAnchor.constraint(equalToConstant: 100),
                iconImageView.heightAnchor.constraint(equalToConstant: 100),
                label.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
                textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                textField.heightAnchor.constraint(equalToConstant: 44),

                actionButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
                actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)

                
            ])
        }


    private func setupBindings() {
        viewModel.onWeatherUpdate = { [weak self] weather in
            guard let self = self else { return }
            self.currentWeather = weather

            DispatchQueue.main.async {
                
                let condition = weather.weather.first?.main ?? ""
                let style = self.getWeatherStyle(for: condition)
                
                self.iconImageView.image = UIImage(systemName: style.symbolName)
                self.iconImageView.tintColor = style.color
                
                self.label.text = "\(weather.name)\n\(Int(weather.main.temp))°C"
            }
        }
    }
}

