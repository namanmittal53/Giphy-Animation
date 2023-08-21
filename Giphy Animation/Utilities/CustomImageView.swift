//
//  ImageExtension.swift
//  Giphy Animation
//
//  Created by Admin on 19/08/23.
//

import Foundation
import UIKit
import ImageIO

class CustomImageView: UIImageView {
    
    var task: URLSessionDataTask!
    private var activityIndicator: UIActivityIndicatorView!

    /// To Download The Image From the URL
    func loadGIF(from urlString: String) {
        
        showLoader()
        
        guard let url = URL(string: urlString) else { return }
        
        if let task = task {
            task.cancel()
        }
        
        // Check cache
        if let cachedImage = GIFCacheManager.shared.cachedGIF(for: url) {
            self.image = cachedImage
            self.hideLoader()
            return
        }
        
        task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image data: \(error)")
                DispatchQueue.main.async {
                    self.image = nil
                    self.hideLoader()
                }
                return
            }
            
            if let data = data {
                DispatchQueue.global().async {
                    let image  = UIImage.gif(data: data)
                                        
                    // Store gif in Cache
                    GIFCacheManager.shared.cacheGIF(data: data, for: url)

                    DispatchQueue.main.async {
                        self.image = image
                        self.hideLoader()
                    }
                }
            }
        }
        task.resume()
    }
    
    // Show the loader at the center of the image view
    private func showLoader() {
        activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func hideLoader() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
}
