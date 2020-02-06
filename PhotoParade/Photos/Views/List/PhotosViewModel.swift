//
//  PhotosViewModel.swift
//  PhotoParade
//
//  Created by Cervenka,Michelle on 2/5/20.
//  Copyright © 2020 Michelle Cervenka. All rights reserved.
//

import Foundation

class PhotosViewModel {
    let searchTerm: String?
    let totalMatches: Total
    var photos: [Int: PhotoViewModel]
    
    init(searchTerm: String?, totalMatches: Total, photos: [Int: PhotoViewModel]) {
        self.searchTerm = searchTerm
        self.totalMatches = totalMatches
        self.photos = photos
    }
}

extension PhotosViewModel {
    func loadMore(start: Int, count: Int) -> Bool {
        switch totalMatches {
        case .total(let total):
            // We'll load more if the total is larger than this index
            guard total > start else { return false }
            
            
            // and the first index is not loaded/loading
            if photos[start] != nil { return false }
            
            setAsLoading(start: start, count: count)
            return true
            
        default:
            return false
        }
    }
    
    func setAsLoading(start: Int, count: Int) {
        for i in start ... start + count where photos[i] == nil {
           photos[i] = .loading
        }
    }
}
