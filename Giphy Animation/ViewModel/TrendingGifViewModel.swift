//
//  TrendingGifVM.swift
//  Giphy Animation
//
//  Created by Admin on 19/08/23.
//

import Foundation
import UIKit

// Protocol
protocol TrendingGifVMDelegate: AnyObject {
    func apiSuccess()
    func apiFailure(errMsg: String)
    func dataReload(index: Int)
}

class TrendingGifViewModel {
    
    // Variables
    weak var delegate: TrendingGifVMDelegate?
    private var modelArray = [GiphyResponseModel]()
    private var searchResultArray: [GiphyResponseModel] = []
    var savedGifUrls: [String] = []

    var totalGifCount: Int {
        return searchResultArray.isEmpty ? modelArray.count : searchResultArray.count
    }
    
    /// To fetch the Trending Giphy Animations from the API
    func fetchTrendingGifs() {
        WebServices.makeAPIRequest(with: .trending, parameters: [:], responseModelType: [GiphyResponseModel].self) { (arr, err) in
            if let modelArray = arr {
                self.modelArray = modelArray
                self.delegate?.apiSuccess()
            }
            if let err = err {
                self.delegate?.apiFailure(errMsg: err.localizedDescription)
            }
        }
    }
    
    // Get GIF Model
    func getGifModelForIndex(index: Int) -> GiphyResponseModel {
        var model = searchResultArray.isEmpty ? self.modelArray[index] : self.searchResultArray[index]
        if savedGifUrls.isEmpty {
            return model
        } else {
            model.isSaved = savedGifUrls.contains(model.images.original.gifURL)
            return model
        }
    }
    
    // Get GIF URL
    func getGifURLForIndex(index: Int) -> String {
        return searchResultArray.isEmpty ? self.modelArray[index].images.original.gifURL : self.searchResultArray[index].images.original.gifURL
    }
    
    // Get GIF Size
    func getGifSizeForIndex(index: Int) -> CGSize {
        var height = Double(self.modelArray[index].images.original.height) ?? 300
        var width = Double(self.modelArray[index].images.original.width) ?? 300
        let aspectRatio = width/height
        
        if width > Double(UIScreen.main.bounds.width - 20) {
            // To maintain the UI & aspect ratio (w/h)
            width = Double(UIScreen.main.bounds.width - 20)
            height = width/aspectRatio
        }
        return CGSize(width: width, height: height)
    }
    
    // Filter Array results
    func searchText(searchTextStr: String) {
        WebServices.makeAPIRequest(with: .search, parameters: [ApiKey.searchQuery: searchTextStr], responseModelType: [GiphyResponseModel].self) { (arr, err) in
            if let modelArray = arr {
                self.searchResultArray = modelArray
                self.delegate?.apiSuccess()
            }
            if let err = err {
                self.delegate?.apiFailure(errMsg: err.localizedDescription)
            }
        }
    }
    
    // Empty the filtered array
    func clearSearch() {
        self.searchResultArray = []
    }
    
    
    // Function for saving GIF in the Core Data
    func saveGifToCoreData(index: Int) {
       let url = self.getGifURLForIndex(index: index)
        DispatchQueue.global().async {
            if let data = UIImage.gif(url: url) {
                CoreDataController.shared.saveGIFData(data: data, url: url) {
                    if !self.savedGifUrls.contains(url) {
                        self.savedGifUrls.append(url)
                    }
                }
                self.delegate?.dataReload(index: index)
            }
        }
    }
    
    // Function for removing GIF in the Core Data
    func removeGifFromCoreData(index: Int) {
        let url = self.getGifURLForIndex(index: index)
        DispatchQueue.global().async {
            CoreDataController.shared.removeGIF(withUrl: url, completion: {
                if self.savedGifUrls.contains(url) {
                    self.savedGifUrls.removeAll { $0 == url }
                }
            })
            self.delegate?.dataReload(index: index)
        }
    }
    
    // Function for fetching GIF URLS from the Core Data
    func fetchGIFURLs() {
        DispatchQueue.global().async {
            self.savedGifUrls = CoreDataController.shared.fetchAllGIFURLs()
        }
    }
}
