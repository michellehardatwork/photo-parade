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
    
    init(photoProvider: PhotoProvider) {
        self.photoProvider = photoProvider
    }
    
    // Cancel any previous searches
    func cancel() {

    }
    
    func search(_ request: PhotoRequest, completion: @escaping (Result<PhotoResult, Error>) -> Void) {
        
    }
}
