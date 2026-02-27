//
//  TrackCell.swift
//  Atmosphere
//
//  Created by İlayda Çelikkaya on 27.02.2026.
//

import UIKit
class TrackCell: UITableViewCell {
    private let coverImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true //taşanları kes
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 10
        iv.translatesAutoresizingMaskIntoConstraints = false

        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18,weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private let artistLabel: UILabel = {
        let l=UILabel()
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .lightGray
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 4
        
        return stack
    }()
    
    func configure(with track: Track) {
        titleLabel.text = track.trackName
        artistLabel.text = track.artistName
        
        if let urlString = track.artworkUrl100,
           let url = URL(string: urlString) {
            
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.coverImageView.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
    }
    
    static let identifier = "TrackCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) { // hücre oluşturulurken benim kodum çalışacak.
        super.init(style: style, reuseIdentifier: reuseIdentifier) //önce apple kurulumu
        contentView.addSubview(coverImageView)
        contentView.addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(artistLabel)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        NSLayoutConstraint.activate([
            coverImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            coverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            coverImageView.widthAnchor.constraint(equalToConstant: 80),
            coverImageView.heightAnchor.constraint(equalToConstant: 80),
            textStackView.leadingAnchor.constraint(equalTo: coverImageView.trailingAnchor, constant: 15),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            textStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
