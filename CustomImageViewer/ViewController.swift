//
//  ViewController.swift
//  CustomImageViewer
//
//  Created by Cstars on 2017/1/24.
//  Copyright © 2017年 cstars. All rights reserved.
//

import UIKit
import SnapKit
class ViewController: UIViewController {
    var imgs = [#imageLiteral(resourceName: "a"),#imageLiteral(resourceName: "b"),#imageLiteral(resourceName: "c"),#imageLiteral(resourceName: "d"),#imageLiteral(resourceName: "e"),#imageLiteral(resourceName: "f")]
    var imgUrls = ["http://i4.piimg.com/11340/7f638e192b9079e6.jpg",
                   "http://pic.58pic.com/58pic/11/25/25/46j58PICKMh.jpg",
                   "http://image103.360doc.com/DownloadImg/2017/01/2904/90248410_11.jpeg",
                   "http://pic1.win4000.com/wallpaper/9/570cc73f275b2.jpg",
                   "http://img.tuku.cn/file_big/201502/0e93d8ab02314174a933b5f00438d357.jpg",
                   "http://image103.360doc.com/DownloadImg/2017/01/2904/90248410_10.jpeg"]
    var previewer: CS_Previewer?
    override func viewDidLoad() {
        super.viewDidLoad()
        let previewer = CS_Previewer(frame: CGRect.zero)
        previewer.imgs = self.imgs
        previewer.imgClickedAction = { [weak self](index) in
            let originalVc = CS_OriginalViewerController()
            originalVc.thumbnails = (self?.imgUrls)!
            originalVc.imgUrls = self?.imgUrls
            originalVc.curSelectedIndex = index
            originalVc.placeHolderImg = #imageLiteral(resourceName: "test1.jpg")
            self?.present(originalVc, animated: true, completion: nil)
        }
        self.previewer = previewer
        self.view.addSubview(previewer)
        self.previewer?.snp.makeConstraints({ (maker) in
            maker.top.equalTo(50)
            maker.leading.trailing.equalToSuperview()
            maker.height.equalTo(100)
        })
        previewer.backgroundColor = UIColor.gray
        
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
    }


    func backFrom(index: Int) {
        self.previewer?.backFrom(index: index)
    }

}

