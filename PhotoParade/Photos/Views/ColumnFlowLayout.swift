//
//  ColumnFlowLayout.swift
//  HEBBuddy
//
//  Created by Cervenka, Michelle on 12/10/17.
//  Copyright © 2017 Michelle Cervenka. All rights reserved.
//

import UIKit

// Collection flow layout that forces the given number of columns when vertically scrolling and rows when horizontally scrolling.
class ColumnFlowLayout: UICollectionViewFlowLayout {
    
    //The number of columns when vertically scrolling and rows when horizontally scrolling.
    let lines: Int
    
    override var itemSize: CGSize {
        get {
            guard let collectionView = collectionView else { return super.itemSize }
            
            if scrollDirection == .vertical {
                let marginsAndInsets = sectionInset.left + sectionInset.right + minimumInteritemSpacing * CGFloat(lines - 1)
                let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(lines)).rounded(.down)
                return CGSize(width: itemWidth, height: itemWidth)
            } else {
                let marginsAndInsets = sectionInset.top + sectionInset.bottom + minimumInteritemSpacing * CGFloat(lines - 1)
                let itemWidth = ((collectionView.bounds.size.height - ( marginsAndInsets)) / CGFloat(lines)).rounded(.down)
                return CGSize(width: itemWidth, height: itemWidth)
            }
            
        }
        set {
            super.itemSize = newValue
        }
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        if scrollDirection == .vertical, UIDevice.current.orientation.isLandscape {
            self.scrollDirection = .horizontal
        } else if scrollDirection == .horizontal, UIDevice.current.orientation.isPortrait {
            self.scrollDirection = .vertical
        }
    }
    
    init(lines: Int, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 0, sectionInset: UIEdgeInsets = .zero) {
        self.lines = lines
        super.init()
        
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
