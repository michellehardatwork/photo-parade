//
//  PhotoService.swift
//  HEBBuddy
//
//  Created by Cervenka, Michelle on 12/8/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]

class PhotoService {
    let photoProvider: PhotoProvider
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    init(photoProvider: PhotoProvider) {
        self.photoProvider = photoProvider
    }
    
    // Cancel any previous searches
    func cancel() {
        dataTask?.cancel()
    }
    
    func search(_ request: PhotoRequest, completion: @escaping (Result<PhotoResult, Error>) -> Void) {
        // TODO: get data
        
        DispatchQueue.main.async {
            completion(Result.failure(PhotoServiceError.unexpectedHttpResponse))
        }
    }
}
