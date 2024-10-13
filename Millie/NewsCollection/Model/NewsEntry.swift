//
//  NewsEntry.swift
//  Millie
//
//  Created by 현은백 on 10/9/24.
//

import Foundation
import UIKit

// MARK: - NewsEntry
struct NewsEntry: Decodable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}
