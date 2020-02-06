//
//  PhotoCollectionViewCell.swift
//  HEBBuddy
//
//  Created by Cervenka, Michelle on 12/8/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import UIKit

// The cell will fetch the image as the cell becomes visible.  It gives us an opportunity to display
// an empty image or error message.
class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    var imageDataTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        imageDataTask?.cancel()
        imageView.image = nil
    }
    
    var photo: Photo? {
        didSet {
            if let photo = photo {
                titleLabel.text = photo.title
                self.imageDataTask = imageView.image(with: photo.imageURL)
            }
        }
    }
}

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

