//
//  UIImageView+Extensions.swift
//  PhotoParade
//
//  Created by Cervenka,Michelle on 2/6/20.
//  Copyright © 2020 Michelle Cervenka. All rights reserved.
//

import UIKit

extension UIImageView {

    // TODO: Cache images
    // TODO: Show an error image
    // TODO: Show a default image
    public func image(with url: String) -> URLSessionDataTask? {
        guard let urlRequest = NSURL(string: url) as URL? else {
            return nil
        }

        let dataTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, _, error) -> Void in

            if let error = error {
                if (error as NSError).code != NSURLErrorCancelled {
                    //We expect a cancelled request since we are the ones cancelling it so don't
                    //clutter the logs
                    print("Error while requesting photo \(url): \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                print("No data found for \(url)")
                return
            }

            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data)
                self.image = image
            })

        })

        dataTask.resume()
        return dataTask
    }
}
