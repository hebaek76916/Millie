//
//  NewsEntry.swift
//  Millie
//
//  Created by 현은백 on 10/9/24.
//

import Foundation

// MARK: - NewsEntry
struct NewsEntry: Decodable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}

// MARK: - Article
struct Article: Decodable {
    let source: Source?
    let author: String?
    let title: String?
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String?//Date?
    let content: String?
}

// MARK: - Source
struct Source: Decodable {
    let id: String?
    let name: String?
}
