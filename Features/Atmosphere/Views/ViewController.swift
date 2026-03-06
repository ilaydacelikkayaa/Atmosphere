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
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let cityLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 23, weight: .semibold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let temperatureLabel: UILabel = {
        let l = UILabel()
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 40, weight: .bold)
        l.textColor = .white
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let descriptionLabel: UILabel = {
        let l = UILabel()
        l.numberOfLines = 0
        l.textAlignment = .center
        l.font = .systemFont(ofSize: 15, weight: .medium)
        l.textColor = .white.withAlphaComponent(0.7) // Hafif şeffaflık profesyonel durur
        l.text = "Atmosferini keşfetmek için bir şeyler yaz..."
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(" Bu Anı Mühürle", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.setImage(UIImage(systemName: "sparkles"), for: .normal)
        button.imageView?.tintColor = .white
        button.semanticContentAttribute = .forceLeftToRight
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
        tf.backgroundColor = UIColor(red: 0.12, green: 0.12, blue: 0.2, alpha: 1)
        tf.layer.cornerRadius = 16
        tf.textColor = .white
        tf.font = .systemFont(ofSize: 16, weight: .medium)
        tf.attributedPlaceholder = NSAttributedString(
                string: "Ne yapmak istiyorsun?",
                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
            )
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 44))
            tf.leftView = paddingView
            tf.leftViewMode = .always
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
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)

        button.tintColor = .white

        button.backgroundColor = UIColor(
            red: 88/255,
            green: 86/255,
            blue: 214/255,
            alpha: 1
        )

        button.layer.cornerRadius = 18

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.3
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
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

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
        
        descriptionLabel.text = "Atmosferin analiz ediliyor..."
        
        guard let userInput = textField.text, !userInput.isEmpty else { return }

        let weatherInfo = "\(cityLabel.text ?? "") \(temperatureLabel.text ?? "")"
        
        aiService.generateMusicQuery(weather: weatherInfo, userInput: userInput) { [weak self] response in
            guard let self = self, let response = response else { return }
            
            let components = response.components(separatedBy: "|")
            let searchTerm = components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let explanation = components.last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            DispatchQueue.main.async {
                self.descriptionLabel.text = explanation
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
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
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.tracks = tracks
                self.tableView.reloadData()
                self.descriptionLabel.text = "İşte atmosferine uygun şarkılar!"
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
       
        view.addSubview(headerView)
            view.addSubview(tableView)
            
            headerView.addSubview(iconImageView)
            headerView.addSubview(descriptionLabel)
            headerView.addSubview(textField)
            headerView.addSubview(actionButton)
            headerView.addSubview(saveButton)
            headerView.addSubview(cityLabel)
            headerView.addSubview(temperatureLabel)
         NSLayoutConstraint.activate([
                    headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    headerView.bottomAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 20),

                    iconImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30),
                    iconImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                    iconImageView.widthAnchor.constraint(equalToConstant: 100),
                    iconImageView.heightAnchor.constraint(equalToConstant: 100),

                    cityLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 12),
                    cityLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
                    cityLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),

                    temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 4),
                    temperatureLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

                    descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 8),
                    descriptionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
                    descriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),

                    textField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
                    textField.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 30),
                    textField.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -30),
                    textField.heightAnchor.constraint(equalToConstant: 50),

                    actionButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
                    actionButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                    actionButton.widthAnchor.constraint(equalToConstant: 220),
                    actionButton.heightAnchor.constraint(equalToConstant: 52),

                    saveButton.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 15),
                    saveButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
                    saveButton.widthAnchor.constraint(equalToConstant: 200),
                    saveButton.heightAnchor.constraint(equalToConstant: 44),

                    tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
                    tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
        
        cityLabel.isUserInteractionEnabled = true
        let cityTap = UITapGestureRecognizer(target: self, action: #selector(changeCityTapped))
        cityLabel.addGestureRecognizer(cityTap)
    }
    @objc private func changeCityTapped() {
        let alert = UIAlertController(title: "Şehir Değiştir", message: "Görmek istediğin şehri yaz.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Örn: İstanbul" }
        
        let updateAction = UIAlertAction(title: "Güncelle", style: .default) { [weak self] _ in
            if let newCity = alert.textFields?.first?.text, !newCity.isEmpty {
                self?.viewModel.fetchWeather(for: newCity)
            }
        }
        
        alert.addAction(updateAction)
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        present(alert, animated: true)
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
                
                self.cityLabel.text = weather.name
                self.temperatureLabel.text = "\(Int(weather.main.temp))°"            }
        }
    }
 

    @objc private func saveMomentTapped() {
        let alert = UIAlertController(title: "Anı Mühürle", message: "Bu ana bir şarkı ve not bırak...", preferredStyle: .alert)
        
        alert.addTextField { $0.placeholder = "Hangi şarkı çalıyor? (Örn: Müslüm Gürses - Nilüfer)" }
        alert.addTextField { $0.placeholder = "Şu anki hissin..." }
        
        let saveAction = UIAlertAction(title: "Kaydet", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let songName = alert.textFields?[0].text ?? "Bilinmeyen Şarkı"
            let note = alert.textFields?[1].text ?? ""
            
            self.persistCustomSnapshot(note: note, song: songName)
        }
        
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Vazgeç", style: .cancel))
        present(alert, animated: true)
    }
    
    
    private func persistCustomSnapshot(note: String, song: String) {
        musicService.searchMusic(term: song) { [weak self] tracks in
                guard let self = self else { return }
        let foundTrack = tracks.first
            DispatchQueue.main.async {
                        let defaults = UserDefaults.standard
                        var snapshots = [AtmosphereSnapshot]()
                        
                        if let savedData = defaults.data(forKey: "AtmosphereHistory"),
                           let decoded = try? JSONDecoder().decode([AtmosphereSnapshot].self, from: savedData) {
                            snapshots = decoded
                        }
                        
                        let newSnapshot = AtmosphereSnapshot(
                            date: Date(),
                            weather: "\(self.cityLabel.text ?? "") \(self.temperatureLabel.text ?? "")",
                            note: note,
                            songName: song,
                            artistName: foundTrack?.artistName ?? "",
                            artworkUrl: foundTrack?.artworkUrl100 ?? ""
                        )
                        
                        snapshots.append(newSnapshot)
                        
                        if let encoded = try? JSONEncoder().encode(snapshots) {
                            defaults.set(encoded, forKey: "AtmosphereHistory")
                        }
                    }
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
        guard let urlString = track.trackViewUrl, let url = URL(string: urlString) else { return }
        
        UIApplication.shared.open(url)
    }
}
