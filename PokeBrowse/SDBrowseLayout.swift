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
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    private var radius: CGFloat {
        get {
            guard let collectionView = self.collectionView else { return CGFloat(0) }
            return min(collectionView.frame.width, collectionView.frame.height) / 2.0
        }
    }
    
    override func prepare()
    {
        guard let collectionView = self.collectionView else {
            return
        }
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let r = min(collectionView.frame.width, collectionView.frame.height) / 2.0
        
        self.layoutAttributes = (0..<numberOfItems).map {
            [itemWidth = self.itemWidth, itemHeight = self.itemHeight] index in
            
            let attribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            let theta = 2 * CGFloat.pi * CGFloat(index) / CGFloat(numberOfItems) + 2 * CGFloat.pi *  collectionView.contentOffset.x / collectionView.contentSize.width
            
            
            attribute.frame = CGRect(x: collectionView.frame.midX + collectionView.contentOffset.x + r * cos(theta), y: collectionView.frame.midY + r * sin(theta), width: itemWidth, height: itemHeight)
            
            return attribute
        }
    }
    
    override var collectionViewContentSize: CGSize {
        get {
            guard let collectionView = self.collectionView else {
                return CGSize.zero
            }
            
            let width = 2 * CGFloat.pi * self.radius
            return CGSize(width: width, height: collectionView.bounds.height)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?
    {
        return layoutAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
        return self.layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool
    {
        return true
    }
}
