//
//  CS_CenterDistributionFlowLayout.swift
//  CustomImageViewer
//
//  Created by Cstars on 2017/2/7.
//  Copyright © 2017年 cstars. All rights reserved.
//

import UIKit

class CS_CenterDistributionFlowLayout: UICollectionViewFlowLayout {
    override var collectionViewContentSize: CGSize {        
        let contentSize = super.collectionViewContentSize
        if self.scrollDirection == .horizontal {
            if contentSize.width > (self.collectionView?.bounds.size.width)! {
                return super.collectionViewContentSize
            } else {
                return (self.collectionView?.bounds.size)!
            }
        } else {
            //忽略所有header,footer,inset,只计算第一个section
            let itemCount = self.collectionView?.numberOfItems(inSection: 0)
            let collectionViewW = (self.collectionView?.bounds.size.width)!
            var beyondCount =  Int((collectionViewW - self.sectionInset.left - self.sectionInset.right + self.minimumInteritemSpacing) / (self.minimumInteritemSpacing + self.itemSize.width))
            beyondCount  = beyondCount > 0 ? beyondCount : 1
            let rowCount = (itemCount!-1) / beyondCount + 1
            
            let height = CGFloat(rowCount) * itemSize.height + CGFloat(rowCount-1) * minimumLineSpacing
            
            return CGSize(width: (self.collectionView?.bounds.size.width)!, height: height)
        }
        
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        for section in 0..<(self.collectionView?.numberOfSections)! {
            let itemCount = self.collectionView?.numberOfItems(inSection: section)
            let collectionViewW = (self.collectionView?.bounds.size.width)!

            var beyondCount =  Int((collectionViewW - self.sectionInset.left - self.sectionInset.right + self.minimumInteritemSpacing) / (self.minimumInteritemSpacing + self.itemSize.width))
            beyondCount  = beyondCount > 0 ? beyondCount : 1

            if self.scrollDirection == .vertical {
                //scroll vertical
                let rowCount = (itemCount!-1) / beyondCount + 1
                //居中
                if let attributes = super.layoutAttributesForElements(in: rect) {
                    var attris = [UICollectionViewLayoutAttributes]()
                    for attr in attributes {
                        let attrCopy = attr.copy() as! UICollectionViewLayoutAttributes
                        attris.append(attrCopy)
                    }
                    let attrsRes = attris.map({ [weak self](attr) -> UICollectionViewLayoutAttributes in
                        let row = attr.indexPath.item / beyondCount
                        let col = attr.indexPath.item % beyondCount
                        var contentW: CGFloat = 0
                        if row != rowCount-1 {
                            contentW = CGFloat(beyondCount) * (self?.itemSize.width)! + CGFloat(beyondCount-1) * (self?.minimumInteritemSpacing)!
                        } else {
                            let lastRowColCount = itemCount! % beyondCount == 0 ? beyondCount : itemCount! % beyondCount
                            contentW = CGFloat(lastRowColCount) * (self?.itemSize.width)! + CGFloat(lastRowColCount-1) * (self?.minimumInteritemSpacing)!
                        }
                        let firstX = (collectionViewW - contentW) / 2
                        let x = firstX + CGFloat(col) * ((self?.itemSize.width)! + (self?.minimumInteritemSpacing)!)
                        
                        let y = (self?.sectionInset.top)! + CGFloat(row) * ((self?.itemSize.height)! + (self?.minimumLineSpacing)!)
                        attr.frame.origin = CGPoint(x: x, y: y)
                        return attr
                    })
                    
                    return attrsRes
                }

            } else {
                let isBeyond = itemCount! > beyondCount
                let contentW = CGFloat(itemCount!) * self.itemSize.width + CGFloat(itemCount!-1) * self.minimumInteritemSpacing
                if isBeyond {
                    return super.layoutAttributesForElements(in: rect)
                } else {
                    //居中
                    if let attributes = super.layoutAttributesForElements(in: rect) {
                        var attris = [UICollectionViewLayoutAttributes]()
                        for attr in attributes {
                            let attrCopy = attr.copy() as! UICollectionViewLayoutAttributes
                            attris.append(attrCopy)
                        }
                        let attrsRes = attris.map({ [weak self](attr) -> UICollectionViewLayoutAttributes in
                            //scroll horizontal
                            let firstX = (collectionViewW - contentW) / 2
                            let x = firstX + CGFloat(attr.indexPath.item) * ((self?.itemSize.width)! + (self?.minimumInteritemSpacing)!)
                            attr.frame.origin.x = x
                            return attr
                        })
                        
                        return attrsRes
                    }
                }
            }
        }
        return super.layoutAttributesForElements(in: rect)
    }
}
