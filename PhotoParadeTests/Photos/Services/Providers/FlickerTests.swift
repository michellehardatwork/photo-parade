//
//  FlickerTests.swift
//  PhotoParadeTests
//
//  Created by Cervenka, Michelle on 12/10/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import XCTest
@testable import PhotoParade

class FlickerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFlickrURLIsValid() {
        // given
        let request = PhotoRequest(searchTerm: "tomatoes", page: 1)
        let flickrProvider = Flickr()
        
        // when
        let url = flickrProvider.url(request)
        
        // then
        XCTAssertEqual(url, URL(string: "https://api.flickr.com/services/rest?method=flickr.photos.search&api_key=75c792f8a8efecb56625e986731a6745&text=tomatoes&format=json&nojsoncallback=1&per_page=30&page=1&sort=relevance"), "Expected URLs to match")
    }
    
}
