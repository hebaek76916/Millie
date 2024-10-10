//
//  ImageLoader.swift
//  Millie
//
//  Created by 현은백 on 10/10/24.
//


import Alamofire
import UIKit

class ImageLoader {
    
    static let shared = ImageLoader()

    private let imageCache: URLCache = {
        let memoryCapacity = 20 * 1024 * 1024
        let diskCapacity = 100 * 1024 * 1024
        return URLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "imageCache")
    }()

    func loadImage(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }

        let request = URLRequest(url: url)

        if let cachedResponse = imageCache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data)
        {
            return image
        }

        let response = await AF.request(url).serializingData().response

        guard 
            response.response?.statusCode == 200,
            let data = response.data
        else {
            return nil
        }

        if let image = UIImage(data: data) {
            let cachedResponse = CachedURLResponse(response: response.response!, data: data)
            imageCache.storeCachedResponse(cachedResponse, for: request)
            return image
        } else {
            return nil
        }
    }
}
