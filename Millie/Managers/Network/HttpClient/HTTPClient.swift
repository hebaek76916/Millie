//
//  HTTPClient.swift
//  Millie
//
//  Created by 현은백 on 10/9/24.
//
import Foundation
import Alamofire

final class HTTPClient {
    
    static let shared = HTTPClient()

    private init() {}
    
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        let url = endpoint.url()
        
        guard let requestURL = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let encoding: ParameterEncoding = method == .get ? URLEncoding.default : JSONEncoding.default
        
        AF.request(
            requestURL,
            method: method,
            parameters: parameters,
            encoding: encoding,
            headers: headers
        ).responseDecodable(of: T.self) { response in
            switch response.result {
            case .success(let decodedObject):
                completion(.success(decodedObject))
            case .failure(let error):
                completion(.failure(.custom(message: error.localizedDescription)))
            }
        }
    }
    
}
