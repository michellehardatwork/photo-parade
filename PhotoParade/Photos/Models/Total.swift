//
//  Total.swift
//  PhotoParade
//
//  Created by Cervenka,Michelle on 2/5/20.
//  Copyright © 2020 Michelle Cervenka. All rights reserved.
//

import Foundation

enum Total {
    case noTotal
    case total(Int)
}

extension Total {
    var totalIfAny: Int? {
        switch self {
        case .total(let total): return total
        default: return nil
        }
    }
}
