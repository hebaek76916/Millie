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
    
    private let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
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
    
    func configure(with data: Article) {
        self.titleLabel.text = data.title
        //TODO: publishedAt DateFormat 하기
        self.publishedDateLabel.text = data.publishedAt
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
        self.contentView.layer.borderColor = isSelected ? UIColor.red.cgColor : UIColor.clear.cgColor
    }
    
    private func setUpUI() {
        contentView.layer.borderWidth = 1.6
        contentView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.3)
        contentView.layer.cornerRadius = 8

        setTitleImageView()
        setTitleLabel()
        setPublishedAtLabel()
        
        func setTitleImageView() {
            contentView.addSubview(titleImageView)
            NSLayoutConstraint.activate([
                titleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                titleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                titleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                titleImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6)
            ])
        }
        
        func setTitleLabel() {
            contentView.addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: titleImageView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                titleLabel.topAnchor.constraint(equalTo: titleImageView.bottomAnchor, constant: 4)
            ])
        }
        
        func setPublishedAtLabel() {
            contentView.addSubview(publishedDateLabel)
            NSLayoutConstraint.activate([
                publishedDateLabel.trailingAnchor.constraint(equalTo: titleImageView.trailingAnchor),
                publishedDateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
        }
    }
    
}
