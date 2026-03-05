//
//  HistoryViewController.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 26.02.2026.
//

import Foundation
import UIKit

class HistoryViewController: UIViewController {
    
  private  var snapshots = [AtmosphereSnapshot]()
    
    private let collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 25
            layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            
            // Ekran genişliğine göre 2'li yan yana dizilim hesabı
            let width = (UIScreen.main.bounds.width - 60) / 2
            layout.itemSize = CGSize(width: width, height: width * 1.3)
            
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.backgroundColor = .clear
            cv.translatesAutoresizingMaskIntoConstraints = false
            return cv
        }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Atmosfer Günlüğüm"
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0)
        setupCollectionView()
        loadSnapshots()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSnapshots()
        collectionView.reloadData()
    }
    
    private func setupCollectionView(){
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(PolaroidCell.self, forCellWithReuseIdentifier: "PolaroidCell")
        
        NSLayoutConstraint.activate([
                    collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                ])
    }

    private func loadSnapshots() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "AtmosphereHistory"),
           let decoded = try? JSONDecoder().decode([AtmosphereSnapshot].self, from: data) {
            snapshots = decoded.reversed()
        }
    }
    
    
    private func showDetailPolaroid(for snapshot: AtmosphereSnapshot) {
        let overlayView = UIView(frame: view.bounds)
        
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0)
        overlayView.tag = 999 //katmana id atama
        
        let detailView = PolaroidView()
        detailView.configure(with: snapshot)
        detailView.translatesAutoresizingMaskIntoConstraints = false
        detailView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        detailView.alpha = 0
        
        overlayView.addSubview(detailView)
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            detailView.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
            detailView.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
            detailView.widthAnchor.constraint(equalToConstant: 300),
            detailView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        UIView.animate(withDuration: 0.3) {
            overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            detailView.transform = .identity // normal boyutuna getir
            detailView.alpha = 1
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDetail))
        overlayView.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissDetail() {
        if let overlay = view.viewWithTag(999) {
            UIView.animate(withDuration: 0.3, animations: {
                overlay.alpha = 0
            }) { _ in
                overlay.removeFromSuperview()
            }
        }
    }
    
}

extension HistoryViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return snapshots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PolaroidCell", for: indexPath) as! PolaroidCell
        let snapshot = snapshots[indexPath.item]
        cell.configure(with: snapshot)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let snapshot = snapshots[indexPath.item]
        showDetailPolaroid(for: snapshot)
    }
}
