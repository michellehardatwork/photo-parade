//
//  Flickr.swift
//  PhotoParade
//
//  Created by Cervenka, Michelle on 12/8/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import Foundation

struct FlickrResult: Codable {
    struct MetaData: Codable {
        let photo: [FlickrPhoto]
        let total: String
    }
    
    struct FlickrPhoto: Codable {
        let id: String
        let owner: String
        let secret: String
        let server: String
        let farm: Int
        let title: String
        
        func url() -> String {
            return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        }
    }
    
    let photos: MetaData
}

//swiftlint:disable comma
class Flickr: PhotoProvider {
    
    static let APIKeyName = "FLICKR_API_KEY"
    
    private lazy var apiKey: String? = {
        return APIKey.valueForAPI(Flickr.APIKeyName)
    }()
    
    func url(_ request: PhotoRequest) -> URL? {
        guard let apiKey = apiKey else {
            return nil
        }
        
        if var urlComponents = URLComponents(string: "https://api.flickr.com/services/rest") {
            
            urlComponents.queryItems = [
                URLQueryItem(name: "method",         value: "flickr.photos.search"),
                URLQueryItem(name: "api_key",        value: apiKey),
                URLQueryItem(name: "text",           value: request.searchTerm),
                URLQueryItem(name: "format",         value: "json"),
                URLQueryItem(name: "nojsoncallback", value: "1"),
                URLQueryItem(name: "per_page",       value: "\(PhotoRequest.itemsPerPage)"),
                URLQueryItem(name: "page",           value: "\(request.page)"),
                URLQueryItem(name: "sort",           value: "relevance")
            ]
            
            return urlComponents.url
        }
        
        return nil
    }
    
    func photos(_ data: Data?) -> PhotoResult {
        
        let decoder = JSONDecoder()
        
        guard let data = data,
            let flickrPhotos = try? decoder.decode(FlickrResult.self, from: data) else {
                print("Photo Service: No data received or unexpected format")
                return PhotoResult(results: [], totalMatches: .noTotal)
        }
        
        //Transform into generic Photo array
        let photos: [Photo?] = flickrPhotos.photos.photo.map({ (item: Any) -> Photo?  in
            if let flickrPhoto = item as? FlickrResult.FlickrPhoto {
               return Photo(title: flickrPhoto.title, imageURL: flickrPhoto.url())
            }
            return nil
        })
        
        return PhotoResult(results: photos.compactMap { $0 }, totalMatches: .total((Int(flickrPhotos.photos.total) ?? 0)))
    }
    
}
