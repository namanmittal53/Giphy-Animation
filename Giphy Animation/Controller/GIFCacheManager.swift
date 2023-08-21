//
//  GIFCacheManager.swift
//  Giphy Animation
//
//  Created by Admin on 21/08/23.
//

import Foundation
import UIKit

class GIFCacheManager {
    
    static let shared = GIFCacheManager()
    
    private let cache = URLCache(memoryCapacity: 20 * 1024 * 1024, diskCapacity: 100 * 1024 * 1024, diskPath: "GIFCache")
    
    private init() {}
    
    func cachedGIF(for url: URL) -> UIImage? {
        if let cachedResponse = cache.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage.gif(data: cachedResponse.data) {
            return image
        }
        return nil
    }
    
    func cacheGIF(data: Data, for url: URL) {
        let response = URLResponse(url: url, mimeType: "image/gif", expectedContentLength: data.count, textEncodingName: nil)
        let cachedResponse = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
    }
}
