//
//  PhotoSearchTableStateView.swift
//  HEBBuddy
//
//  Created by Cervenka, Michelle on 12/10/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import UIKit

class PhotoSearchTableStateView: UIView {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stateMessageLabel: UILabel!
    
    private lazy var paragraphStyle: NSMutableParagraphStyle = {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineSpacing = 5.0
        return paragraph
    }()
    
    private lazy var titleStyle: [NSAttributedStringKey : Any] = {
        return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.bold),
                NSAttributedStringKey.foregroundColor: UIColor.darkText,
                NSAttributedStringKey.paragraphStyle: self.paragraphStyle]
    }()
    
    private lazy var descriptionStyle: [NSAttributedStringKey : Any] = {
        return [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular),
                NSAttributedStringKey.foregroundColor: UIColor.darkText,
                NSAttributedStringKey.paragraphStyle: self.paragraphStyle]
    }()
    
    func showNothing() {
        activityIndicator.stopAnimating()
        stateMessageLabel.text = ""
        isHidden = true
    }
    
    func showInitial() {
        isHidden = false
        activityIndicator.stopAnimating()
        
        display(title: "Looking for Something?", description: "Use search to explore the world of photos.")
    }
    
    func showSearching() {
        isHidden = false
        activityIndicator.startAnimating()
        stateMessageLabel.text = ""
    }
    
    func showSearched(count: Int) {
        isHidden = false
        activityIndicator.stopAnimating()
        
        if count <= 0 {
            display(title: "No Matches", description: "We don't have THAT photo yet.  You should add it!")
        } else {
            showNothing()
        }
    }
    
    private func display(title: String, description: String) {
        
        let titleString = NSAttributedString(string: title, attributes: titleStyle)
        let descriptionString = NSAttributedString(string: "\n\(description)", attributes: descriptionStyle)
        
        let combination = NSMutableAttributedString()
        combination.append(titleString)
        combination.append(descriptionString)
        
        stateMessageLabel.attributedText = combination
    }
}


