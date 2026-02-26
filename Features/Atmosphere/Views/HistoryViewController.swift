//
//  HistoryViewController.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 26.02.2026.
//

import Foundation
import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource {
    var snapshots = [AtmosphereSnapshot]()
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Atmosfer Günlüğüm"
        view.backgroundColor = .systemBackground
        
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "historyCell")
        view.addSubview(tableView)
        
        loadSnapshots()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSnapshots()
    }

    func loadSnapshots() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "AtmosphereHistory"),
           let decoded = try? JSONDecoder().decode([AtmosphereSnapshot].self, from: data) {
            self.snapshots = decoded.reversed() // En yeni anı en üstte görünsün
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return snapshots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath)
        let snapshot = snapshots[indexPath.row]
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateString = formatter.string(from: snapshot.date)
        
        cell.textLabel?.text = "\(snapshot.weather) - \(dateString)"
        cell.detailTextLabel?.text = "Note: \(snapshot.note) \nMusic: \(snapshot.songName)"
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
}
