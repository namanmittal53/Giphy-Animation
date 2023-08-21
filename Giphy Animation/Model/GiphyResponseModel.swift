//
//  GiphyResponseModel.swift
//  Giphy Animation
//
//  Created by Admin on 19/08/23.
//

import Foundation

struct GiphyResponseModel: Decodable {
    var type: String = ""
    var images: ImagesModel
    var isSaved = false
    
    enum CodingKeys: String, CodingKey {
        case type
        case images
    }
}

struct ImagesModel: Decodable {
    var original: OriginalGifModel
    
    enum CodingKeys: String, CodingKey {
        case original
    }
}

struct OriginalGifModel: Decodable {
    var url: String = ""
    var height: String = ""
    var width: String = ""
    
    var gifURL: String {
        if let firstIndexOfQuestionMark = url.firstIndex(of: "?") {
            return String(url[..<firstIndexOfQuestionMark])
        }
        return ""
    }
    
    enum CodingKeys: String, CodingKey {
        case url
        case height
        case width
    }
}
