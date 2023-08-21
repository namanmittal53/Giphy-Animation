//
//  FavouritesViewModel.swift
//  Giphy Animation
//
//  Created by Admin on 21/08/23.
//

import UIKit
import Foundation

// Protocol
protocol FavGifVMDelegate: AnyObject {
    func fetchGifSuccess()
    func dataReload(index: Int)
}

class FavouritesGifViewModel {
    
    // MARK: - Variables
    weak var delegate: FavGifVMDelegate?
    private var gifArray = [GiphySavedModel]()
    var gifsCount: Int {
        return gifArray.count
    }
    
    // MARK: - Functions
    // Function for fetching GIFs in the Core Data
    func fetchGIFArray() {
        gifArray = []
        DispatchQueue.global().async {
            let dataArr = CoreDataController.shared.fetchAllGIFData()
            let urlArray = CoreDataController.shared.fetchAllGIFURLs()
            for (index, data) in dataArr.enumerated() {
                let img = UIImage.gif(data: data) ?? UIImage()
                self.gifArray.append(GiphySavedModel(image: img, isSaved: true, urlString: urlArray[index]))
            }
            self.delegate?.fetchGifSuccess()
        }
    }
    
    // Get GIF URL
    func getGifURLForIndex(index: Int) -> String {
        return self.gifArray[index].urlString
    }
    
    ///Get Gif for index
    func getGIF(for index: Int) -> GiphySavedModel {
        return self.gifArray[index]
    }
    
    // Function for removing GIF in the Core Data
    func removeGifFromCoreData(index: Int) {
        let url = self.getGifURLForIndex(index: index)
        DispatchQueue.global().async {
            CoreDataController.shared.removeGIF(withUrl: url) {
                self.gifArray.remove(at: index)
            }
            self.delegate?.dataReload(index: index)
        }
    }
}
