//
//  PolaroidCell.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 2.03.2026.
//

import UIKit
class PolaroidCell: UICollectionViewCell {
    static let identifier = "PolaroidCell"
    
    private let polaroidView = PolaroidView()
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        contentView.addSubview(polaroidView)
        polaroidView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                    polaroidView.topAnchor.constraint(equalTo: contentView.topAnchor),
                    polaroidView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                    polaroidView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                    polaroidView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
                ])
    }
        required init?(coder: NSCoder) {
             fatalError()
         }
         
    func configure(with snapshot: AtmosphereSnapshot) {
        polaroidView.configure(with: snapshot)
    }
     }
