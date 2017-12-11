//
//  PhotoService.swift
//  HEBBuddy
//
//  Created by Cervenka, Michelle on 12/8/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import Foundation

typealias JSONDictionary = [String: Any]
typealias PhotoResponse = (Result<PhotoResult>) -> Void

struct PhotoRequest {
    var searchTerm: String?
    var page = 1
    let itemsPerPage = 30
}

struct PhotoResult {
    let results: [Photo]
    let totalMatches: Total
}

enum Total {
    case noTotal
    case total(Int)
}

enum Result<T> {
    case success(T)
    case failure(Error)
}

enum PhotoServiceError: Error {
    case malformedURL
    case unexpectedHttpResponse
}

extension PhotoServiceError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString("Oops!  Something unexpected happened.", comment: "general error message")
    }
}

// Represents a provider that can handle a request to search for photos
protocol PhotoProvider {
    func url(_ request: PhotoRequest) -> URL?
    func photos(_ data: Data?) -> PhotoResult
}

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
    
    func search(_ request: PhotoRequest, completion: @escaping PhotoResponse) {
        
        guard let url = photoProvider.url(request) else {
            completion(Result.failure(PhotoServiceError.malformedURL))
            return
        }
        
        //Make new request to get search results
        dataTask = defaultSession.dataTask(with: url) { data, response, error in
            
            //Checking for error
            if let error = error {
                print("Photo Service: Error while searching photos: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(Result.failure(error))
                }
                return
            }
            
            //Checking HTTP response
            guard let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    print("Photo Service: HTTP error")
                    DispatchQueue.main.async {
                        completion(Result.failure(PhotoServiceError.unexpectedHttpResponse))
                    }
                    return
            }
            
            //Returning photos
            DispatchQueue.main.async {
                completion(Result.success(self.photoProvider.photos(data)))
            }
        }
        
        dataTask?.resume()
    }
}
