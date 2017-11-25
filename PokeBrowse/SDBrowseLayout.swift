//
//  SDBrowseLayout.swift
//  PokeBrowse
//
//  Created by sdaniel on 11/24/17.
//  Copyright © 2017 sdaniel. All rights reserved.
//

import UIKit

class SDBrowseLayout: UICollectionViewLayout
{
    private let itemWidth: CGFloat = 50
    private let itemHeight: CGFloat = 50
    private let spacing: CGFloat = 10
    
    private func itemOffset(_ index: Int) -> CGFloat
    {
        let x = CGFloat(index) * self.itemWidth + self.spacing * max(CGFloat(index), 0.0)
        print("\(index): \(x)")
        if (x < 0) {
            print("break")
        }
        return x
    }
    
    override func prepare()
    {
        print("prepare")
    }
    
    override var collectionViewContentSize: CGSize {
        get {
            guard let collectionView = self.collectionView else {
                return CGSize.zero
            }
            
            let count = collectionView.numberOfItems(inSection: 0)
            let width = self.itemOffset(count) + collectionView.frame.midX
            return CGSize(width: width, height: collectionView.bounds.height)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        guard let collectionView = self.collectionView else {
            return nil
        }
        
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        attributes.frame = CGRect(x: collectionView.frame.midX + self.itemOffset(indexPath.item), y: collectionView.frame.midY, width: self.itemWidth, height: self.itemHeight)
        
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        guard let numberOfItems = self.collectionView?.numberOfItems(inSection: 0) else {
            return nil
        }
        
        let minIndex = Int(floor(max(rect.minX, 0.0) / (self.itemWidth + self.spacing)))
        let count = Int(floor(rect.width / (self.itemWidth + self.spacing)))
        let maxIndex = min(minIndex + count, numberOfItems - 1)
        
        let attributes = (minIndex...maxIndex).map {
            self.layoutAttributesForItem(at: IndexPath(item: $0, section: 0))!
        }
        
        return attributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return true
    }
}
