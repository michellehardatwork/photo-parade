//
//  APIKeys.swift
//  PhotoParade
//
//  Created by Cervenka, Michelle on 12/12/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import Foundation

struct APIKey {
    static func valueForAPI(_ key: String) -> String? {
        // Get the file path for keys.plist
        let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist")
        
        // Put the keys in a dictionary
        let plist = NSDictionary(contentsOfFile: filePath!)
        
        // Pull the value for the key
        // TODO: store the value encoded and decode on reading.
        // TODO: cache these values so we aren't reading from disk every time
        return plist?.object(forKey: key) as? String
    }
}
