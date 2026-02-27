//
//  ViewController.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 18.02.2026.
//

import UIKit

class ViewController: UIViewController {
    let musicService = MusicService()
    let viewModel = WeatherViewModel()
    private var tracks: [Track] = []
    private var currentWeather: WeatherResponse?
    let aiService = AIService()
    private let headerView = UIView()
    private let label: UILabel = {
            let l = UILabel()
            l.numberOfLines = 0 //sınırsız metin gostergesi
            l.textAlignment = .center
            l.font = .systemFont(ofSize: 28, weight: .black)
            l.textColor = .white
            l.text = "Hava Durumu Yükleniyor..."
            l.layer.shadowColor = UIColor.black.cgColor
            l.layer.shadowRadius = 3.0
            l.layer.shadowOpacity = 0.5
            l.layer.shadowOffset = CGSize(width: 2, height: 2)
            l.translatesAutoresizingMaskIntoConstraints = false
            return l
        }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" Bu Anı Mühürle", for: .normal)
        button.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.tintColor = .systemPink
        button.backgroundColor = .systemBackground.withAlphaComponent(0.8)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor //ince cerceve ekliyoruz
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 16, weight: .medium)
        tf.attributedPlaceholder = NSAttributedString(
                string: "Ne yapmak istiyorsun?",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 44))
            tf.leftView = paddingView
            tf.leftViewMode = .always
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .clear
        tv.register(TrackCell.self, forCellReuseIdentifier: TrackCell.identifier)
        tv.rowHeight = 110
        tv.separatorStyle = .none
        tv.backgroundView = nil
        return tv
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Atmosferi Keşfet", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18,weight:.bold)
        button.tintColor = .white
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 22
        button.layer.shadowColor = UIColor.systemIndigo.cgColor
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.5
            button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        
            super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
            setupUI()
            setupBindings()
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        saveButton.addTarget(self, action: #selector(saveMomentTapped), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
            viewModel.fetchWeather(for: "Isparta")
        
        let historyButton = UIButton(type: .system)
        historyButton.setTitle("Günlüğüme Bak", for: .normal)
        historyButton.addTarget(self, action: #selector(showHistory), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Günlük",
            style: .plain,
            target: self,
            action: #selector(showHistory)
        )
        }
    
    @objc func showHistory() {
        let historyVC = HistoryViewController()
        let navController = UINavigationController(rootViewController: historyVC)
        present(navController, animated: true)
    }
    @objc private func buttonTapped() {
        view.endEditing(true)
        label.text = "Atmosferin analiz ediliyor..."
        
        guard let userInput = textField.text, !userInput.isEmpty,
              let weatherInfo = label.text else { return }
        
        aiService.generateMusicQuery(weather: weatherInfo, userInput: userInput) { [weak self] response in
            guard let self = self, let response = response else { return }
            
            let components = response.components(separatedBy: "|")
            let searchTerm = components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let explanation = components.last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            DispatchQueue.main.async {
                self.label.text = explanation
            }
            self.musicService.searchMusic(term: searchTerm) { tracks in
                DispatchQueue.main.async {
                    self.tracks = tracks
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func fetchMusic(with query: String) {
        self.musicService.searchMusic(term: query) { [weak self] tracks in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.tracks = tracks
                self.tableView.reloadData()
                self.label.text = "İşte Atmosferin İçin Seçtiğim Şarkılar!"
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
        view.addSubview(tableView)
        headerView.addSubview(iconImageView)
        headerView.addSubview(label)
        headerView.addSubview(textField)
        headerView.addSubview(actionButton)
        headerView.addSubview(saveButton)

        tableView.tableHeaderView = headerView
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 60),            iconImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 100),
            iconImageView.heightAnchor.constraint(equalToConstant: 100),
            
            label.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 25),
            textField.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
            textField.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),
            textField.heightAnchor.constraint(equalToConstant: 44),

            actionButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            actionButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            saveButton.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 15),
            saveButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 500)
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
 

    @objc private func saveMomentTapped() {
        guard !tracks.isEmpty else {
            let alert = UIAlertController(title: "Hata", message: "Önce bir atmosfer oluşturmalısın!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }

        let alert = UIAlertController(title: "Anı Mühürle", message: "Bu atmosfere bir not bırak...", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Şu anki hissin..." }
        
        let saveAction = UIAlertAction(title: "Kaydet", style: .default) { [weak self] _ in
            if let note = alert.textFields?.first?.text, let firstTrack = self?.tracks.first {
                self?.persistSnapshot(note: note, track: firstTrack)
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        present(alert, animated: true)
    }

    private func persistSnapshot(note: String, track: Track) {
        let defaults = UserDefaults.standard
        var snapshots = [AtmosphereSnapshot]()
        
        if let savedData = defaults.data(forKey: "AtmosphereHistory"),
           let decoded = try? JSONDecoder().decode([AtmosphereSnapshot].self, from: savedData) {
            snapshots = decoded
        }
        
        let newSnapshot = AtmosphereSnapshot(
            date: Date(),
            weather: label.text ?? "Bilinmiyor",
            note: note,
            songName: track.trackName,
            artistName: track.artistName ?? "Bilinmiyor"
        )
        
        snapshots.append(newSnapshot)
        if let encoded = try? JSONEncoder().encode(snapshots) {
            defaults.set(encoded, forKey: "AtmosphereHistory")
            print("Anı başarıyla günlüğe eklendi!") // Konsolda kontrol için
        }
    }
    
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    // Kural 1: Kaç satır olacak?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    // Kural 2: Her satırda ne yazacak?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: TrackCell.identifier,
            for: indexPath
        ) as! TrackCell
        
        let track = tracks[indexPath.row]
        cell.configure(with: track)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let track = tracks[indexPath.row]
        // iTunes'dan gelen 'trackViewUrl' doğrudan Apple Music/iTunes linkidir
        guard let urlString = track.trackViewUrl, let url = URL(string: urlString) else { return }
        
        // Uygulamadan çıkıp şarkıyı Apple Music'te açar
        UIApplication.shared.open(url)
    }
}
