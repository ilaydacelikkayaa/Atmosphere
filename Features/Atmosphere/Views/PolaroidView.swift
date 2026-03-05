import UIKit

class PolaroidView: UIView {
    
    private let albumImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .regular)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let songLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .black
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let noteLabel: UILabel = {
        let label = UILabel()
        label.font = .italicSystemFont(ofSize: 12)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 4
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        
        addSubview(albumImageView)
        addSubview(songLabel)
        addSubview(dateLabel)
        addSubview(noteLabel)
        
        NSLayoutConstraint.activate([
            albumImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            albumImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            albumImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            albumImageView.heightAnchor.constraint(equalTo: albumImageView.widthAnchor), // Kare yapar
            
            songLabel.topAnchor.constraint(equalTo: albumImageView.bottomAnchor, constant: 10),
            songLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            songLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            noteLabel.topAnchor.constraint(equalTo: songLabel.bottomAnchor, constant: 4),
            noteLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            noteLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12)
        ])
        
       
    }
    
    func configure(with snapshot: AtmosphereSnapshot) {
        songLabel.text = snapshot.songName
        noteLabel.text = snapshot.note
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        dateLabel.text = formatter.string(from: snapshot.date)
        
        if let url = URL(string: snapshot.artworkUrl) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data {
                    DispatchQueue.main.async {
                        self.albumImageView.image = UIImage(data: data)
                    }
                }
            } .resume()
        }
    }
}
