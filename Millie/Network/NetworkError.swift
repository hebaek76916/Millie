//
//  NetworkError.swift
//  Millie
//
//  Created by 현은백 on 10/9/24.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case custom(message: String)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .noData:
            return "응답 데이터가 없습니다."
        case .decodingError:
            return "데이터 파싱에 실패했습니다."
        case .custom(let message):
            return message
        }
    }
}
