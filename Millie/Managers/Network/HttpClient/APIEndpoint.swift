//
//  APIEndpoint.swift
//  Millie
//
//  Created by 현은백 on 10/9/24.
//

import Foundation

enum APIEndpoint {
    case topHeadlines(country: String)
    
    var path: String {
        switch self {
        case .topHeadlines:
            return "/top-headlines"
        }
    }
    
    var queryParameters: [String: String] {
        switch self {
        case .topHeadlines(let country):
            return [
                "country": country
            ]
        }
    }
}

extension APIEndpoint {
    
    func url() -> String {
        var components = URLComponents(string: APIConstants.baseURL)
        components?.path += path
        
        var queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        let apiKeyItem = URLQueryItem(name: "apiKey", value: APIConstants.apiKey)
        queryItems.append(apiKeyItem)
        
        components?.queryItems = queryItems
        
        return components?.url?.absoluteString ?? ""
    }
}
