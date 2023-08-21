//
//  WebServices.swift
//  Giphy Animation
//
//  Created by Admin on 19/08/23.
//

import Foundation

enum EndPoints: String {
    case trending = "https://api.giphy.com/v1/gifs/trending"
    case search = "https://api.giphy.com/v1/gifs/search"
    
    var value: String {
        return self.rawValue
    }
}

class WebServices {
    
    // Writing a demo API Function in the Network Layer for the Demo/Test Project
    
    ///  This is a common function used for making API requests
    static func makeAPIRequest<T: Decodable>(with urlString: EndPoints, parameters: [String: String], responseModelType: T.Type, completion: @escaping ((T?, Error?) -> Void)) {
        
        guard var components = URLComponents(string: urlString.value) else {
            print("Invalid URL String.")
            completion(nil, nil)
            return
        }
        var params: [String:String] = parameters
        params[ApiKey.apiKey] = AppConstants.apiKEY
        
        components.queryItems = params.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        
        guard let url = components.url else {
            print("Cannot form the URL.")
            completion(nil, nil)
            return
        }
        print("=========== URL Request ========= ")
        print(url)
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let data = data {
                let model = self.parseData(data: data, responseModel: responseModelType).res
                let err = self.parseData(data: data, responseModel: responseModelType).e
                completion(model, err)
            }
            
            if let err = error {
                print(err.localizedDescription)
                completion(nil, error)
            }
        }.resume()
    }
    
    
    // To Parse The Data from the JSON Data
    static func parseData<T: Decodable>(data: Data, responseModel: T.Type) -> (res: T?, e: Error?) {
        do {
            if let jsonDataDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("=========== Response ========= ")
                print(jsonDataDict)
                
                let dataDictionary = jsonDataDict[ApiKey.data] as? [[String: Any]] ?? []
                let objectData = try JSONSerialization.data(withJSONObject: dataDictionary, options: [])
                let responseModel = try JSONDecoder().decode(responseModel, from: objectData)
                return (responseModel, nil)
            }
            return (nil, nil)
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
            return (nil, error)
        }
    }
    
}
