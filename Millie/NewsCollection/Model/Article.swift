//
//  Article.swift
//  Millie
//
//  Created by 현은백 on 10/13/24.
//

import Foundation

// MARK: - Article
struct Article: Decodable, Identifiable {
    var id: String = UUID().uuidString
    let source: Source?
    let author: String?
    let title: String?
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    
    var isSelected: Bool = false
    mutating func setIsSelected(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    private enum CodingKeys: String, CodingKey {
        case source
        case author
        case title
        case description
        case url
        case urlToImage
        case publishedAt
        case content
    }
    
    // MARK: - Source
    struct Source: Decodable {
        let id: String?
        let name: String?
    }
}
