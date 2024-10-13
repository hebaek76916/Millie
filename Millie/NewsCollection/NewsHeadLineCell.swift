//
//  NewsHeadLineCell.swift
//  Millie
//
//  Created by 현은백 on 10/10/24.
//

import UIKit

class NewsHeadLineCell: UICollectionViewCell, ReusableCell {

    typealias DataType = Article
    
    static let identifier = "NewsHeadLineCell"
    
    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.backgroundColor = MillieConstant.titleColor
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let publishedDateLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .right
        lbl.font = UIFont.systemFont(ofSize: 8, weight: .medium)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let titleImageView: UIImageView = {
        let v = UIImageView()
        v.clipsToBounds = true
        v.backgroundColor = .black.withAlphaComponent(0.64)
        v.contentMode = .scaleAspectFill
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        titleImageView.image = nil
        publishedDateLabel.text = nil
        setSelectedUI(isSelected: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayout(for: traitCollection)
    }
    
    func configure(with data: Article) {
        self.titleLabel.text = data.title
        self.publishedDateLabel.text = data.publishedAt?.toFormattedDateString()
        if let imageURLString = data.urlToImage {
            Task {
                if let image = try? await ImageLoader.shared.loadImage(from: imageURLString) {
                    DispatchQueue.main.async {
                        self.titleImageView.image = image
                    }
                }
            }
        }
        
        setSelectedUI(isSelected: data.isSelected)
    }
}

//MARK: Set Up UI
extension NewsHeadLineCell {

    private func setSelectedUI(isSelected: Bool) {
        self.titleLabel.textColor = isSelected ? .red : .black
        self.publishedDateLabel.textColor = isSelected ? .red : .black
        self.contentView.layer.borderColor = isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
    }
    
    private func updateLayout(for traitCollection: UITraitCollection) {
        if traitCollection.verticalSizeClass == .compact {//Landscape
            NSLayoutConstraint.deactivate(portraitConstraints)
            NSLayoutConstraint.activate(landscapeConstraints)
            contentView.layer.cornerRadius = 8
            titleLabel.backgroundColor = .clear
            titleLabel.numberOfLines = 1
            titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        } else {//Portrait
            NSLayoutConstraint.deactivate(landscapeConstraints)
            NSLayoutConstraint.activate(portraitConstraints)
            contentView.layer.cornerRadius = 2.0
            titleLabel.backgroundColor = .white
            titleLabel.numberOfLines = 3
            titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        }
    }
    
    private func setUpUI() {
        contentView.layer.borderWidth = 2.0
        contentView.backgroundColor = MillieConstant.titleColor.withAlphaComponent(0.6)
        [
            titleImageView, titleLabel, publishedDateLabel
        ].forEach { contentView.addSubview($0) }
        
        setPortraitConstraints()
        setLandScapeConstraints()
        
        updateLayout(for: traitCollection)

        func setLandScapeConstraints() {
            landscapeConstraints = [
                titleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                titleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                titleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                titleImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6),
                
                titleLabel.leadingAnchor.constraint(equalTo: titleImageView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                titleLabel.topAnchor.constraint(equalTo: titleImageView.bottomAnchor, constant: 4),
                
                publishedDateLabel.trailingAnchor.constraint(equalTo: titleImageView.trailingAnchor),
                publishedDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ]
        }
        
        func setPortraitConstraints() {
            portraitConstraints = [
                titleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -30),
                titleImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.8),
                titleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                titleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
                
                titleLabel.leadingAnchor.constraint(equalTo: titleImageView.trailingAnchor, constant: -30),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                titleLabel.topAnchor.constraint(equalTo: titleImageView.topAnchor),
                
                publishedDateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                publishedDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                publishedDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ]
        }

    }
    
    
    
}
