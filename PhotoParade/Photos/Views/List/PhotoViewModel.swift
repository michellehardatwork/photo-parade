//
//  PhotoViewModel.swift
//  PhotoParade
//
//  Created by Cervenka,Michelle on 2/5/20.
//  Copyright © 2020 Michelle Cervenka. All rights reserved.
//

import Foundation

struct PhotoViewContentModel {
    let photo: Photo
}

enum PhotoViewModel {
    case loading
    case loaded(PhotoViewContentModel)
    case error
}

extension PhotoViewModel {
    var photoIfAny: Photo? {
        switch self {
        case .loaded(let model): return model.photo
        default: return nil
        }
    }
}

extension Sequence where Element == Photo {
    func convertToViewModel(startIndex: Int) -> [Int: PhotoViewModel] {
        var viewModel = [Int: PhotoViewModel]()
        
        for (index, photo) in self.enumerated() {
            viewModel[startIndex + index] = PhotoViewModel.loaded(PhotoViewContentModel(photo: photo))
        }
        
        return viewModel
    }
}
