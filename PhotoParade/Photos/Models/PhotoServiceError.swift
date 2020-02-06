//
//  PhotoServiceError.swift
//  PhotoParade
//
//  Created by Cervenka,Michelle on 2/5/20.
//  Copyright © 2020 Michelle Cervenka. All rights reserved.
//

import Foundation

enum PhotoServiceError: Error {
    case malformedURL
    case unexpectedHttpResponse
}

extension PhotoServiceError: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString("Oops!  Something unexpected happened.", comment: "general error message")
    }
}
