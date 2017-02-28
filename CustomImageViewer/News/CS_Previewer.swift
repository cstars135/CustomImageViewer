//
//  CS_Previewer.swift
//  CustomImageViewer
//
//  Created by Cstars on 2017/1/24.
//  Copyright © 2017年 cstars. All rights reserved.
//

import UIKit
import AlamofireImage
import SnapKit
class CS_Previewer: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    public var imgs: [UIImage]?
    public var imgUrls: [String]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    public var placeHolderImg: UIImage?

    var imgClickedAction: ((Int) -> Void)?
    var collectionView: UICollectionView
    
    override init(frame: CGRect) {
        let flowLayOut = CS_CenterDistributionFlowLayout()
        flowLayOut.itemSize = CGSize(width: 50, height: 50)
        flowLayOut.scrollDirection = .horizontal
        flowLayOut.minimumLineSpacing = 10
        flowLayOut.minimumInteritemSpacing = 10
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayOut)
        collectionView.backgroundColor = UIColor.red
        collectionView.register(UINib(nibName: "CS_ThumbnailCell", bundle: nil), forCellWithReuseIdentifier: "CS_ThumbnailCell")
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        collectionView.showsHorizontalScrollIndicator = false
        super.init(frame: frame)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.frame = self.bounds
        self.addSubview(collectionView)
        self.collectionView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let flowLayOut = CS_CenterDistributionFlowLayout()
        flowLayOut.itemSize = CGSize(width: 50, height: 50)
        flowLayOut.scrollDirection = .horizontal
        flowLayOut.minimumLineSpacing = 10
        flowLayOut.minimumInteritemSpacing = 10
        self.collectionView.setCollectionViewLayout(flowLayOut, animated: false)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func backFrom(index: Int) {
        self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    //MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let imgUrls = self.imgUrls {
            return imgUrls.count
        }
        
        if let imgs = self.imgs {
            return imgs.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CS_ThumbnailCell", for: indexPath) as! CS_ThumbnailCell
        cell.index = indexPath.item
        if let imgUrls = self.imgUrls {
            if let imgUrl = URL(string: imgUrls[indexPath.item] as String) {
                cell.imgView.af_setImage(withURL: imgUrl, placeholderImage: self.placeHolderImg)
            } else {
                cell.imgView.image = self.placeHolderImg
            }
        } else if let imgs = self.imgs {
            cell.imgView.image = imgs[indexPath.row]
        }
        return cell
    }
    
    
    //MARK: - Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row)")
        if let action = self.imgClickedAction {
            action(indexPath.item)
        }
    }
}
