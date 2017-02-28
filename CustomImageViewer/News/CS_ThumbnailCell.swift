//
//  CS_ThumbnailCell.swift
//  CustomImageViewer
//
//  Created by Cstars on 2017/1/24.
//  Copyright © 2017年 cstars. All rights reserved.
//

import UIKit
import Hero

class CS_ThumbnailCell: UICollectionViewCell {
    var index: Int? {
        didSet {
           heroID = "map\(index)"
        }
    }
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgView.layer.cornerRadius = 3
        self.imgView.layer.masksToBounds = true
    }

}
