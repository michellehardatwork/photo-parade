//
//  PhotoProvider.swift
//  PhotoParade
//
//  Created by Cervenka,Michelle on 2/5/20.
//  Copyright © 2020 Michelle Cervenka. All rights reserved.
//

import Foundation

// Represents a provider that can handle a request to search for photos
protocol PhotoProvider {
    func url(_ request: PhotoRequest) -> URL?
    func photos(_ data: Data?) -> PhotoResult
}
