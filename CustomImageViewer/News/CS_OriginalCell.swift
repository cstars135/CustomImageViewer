//
//  CS_OriginalCell.swift
//  CustomImageViewer
//
//  Created by Cstars on 2017/1/24.
//  Copyright © 2017年 cstars. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Photos
import MBProgressHUD

class CS_OriginalCell: UICollectionViewCell, UIScrollViewDelegate {
    var originalUrl: String?
    var hud: NVActivityIndicatorView?
    
    var index: Int? {
        didSet {
            heroID = "map\(index)"
        }
    }
    
    var dismissAction: (()->Void)?
    
    @IBOutlet weak var scrollView: UIScrollView!
    var imgView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgView.contentMode = .scaleAspectFit
        imgView.frame = self.bounds
        self.scrollView.contentMode = .center
        self.scrollView.minimumZoomScale = 1
        self.scrollView.maximumZoomScale = 3
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.delegate = self
        self.scrollView.addSubview(imgView)
        
        
        let doubleTapGes = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapped(ges:)))
        doubleTapGes.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTapGes)
        
        let singleTapGes = UITapGestureRecognizer(target: self, action: #selector(self.singleTapped(ges:)))
        singleTapGes.require(toFail: doubleTapGes)
        singleTapGes.numberOfTapsRequired = 1
        self.addGestureRecognizer(singleTapGes)
        
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(ges:)))
        self.addGestureRecognizer(longPressGes)
        
        let x = UIScreen.main.bounds.size.width / 2 - 20
        let y = UIScreen.main.bounds.size.height / 2 - 20
        let frame = CGRect(x: x, y: y, width: 40, height: 40)
        let hud = NVActivityIndicatorView(frame: frame, type: .ballClipRotateMultiple)
        hud.isHidden = true
        self.contentView.addSubview(hud)
        self.hud = hud
    }
    
    func singleTapped(ges: UITapGestureRecognizer) {
        if let dismissAction = self.dismissAction {
            dismissAction()
        }
    }
    
    func doubleTapped(ges: UITapGestureRecognizer) {
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: scrollView.maximumZoomScale, center: ges.location(in: ges.view)), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func longPress(ges: UILongPressGestureRecognizer) {
        if ges.state == .began {
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status != .authorized {
                        DispatchQueue.main.async {
                            let authoAlertVc = UIAlertController(title: "请到设置开启相册访问权限", message: nil, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "好", style: .default, handler: nil)
                            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
                            authoAlertVc.addAction(okAction)
                            authoAlertVc.addAction(cancelAction)
                            viewTopVc(responder: self)?.present(authoAlertVc, animated: true, completion: nil)
                        }
                        return
                    } else {
                        self.showSaveAlert()
                    }
                })
            } else {
                self.showSaveAlert()
            }
        }
    }
    
    func showSaveAlert() {
        let alertVc = UIAlertController(title: "要保存图片吗?", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "确定", style: .default, handler: { (saveAction) in
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: self.imgView.image!)
            }, completionHandler: { (isSuccess, error) in
                DispatchQueue.main.async {
                    let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
                    hud.mode = .text
                    hud.removeFromSuperViewOnHide = true
                    if isSuccess {
                        hud.label.text = "保存成功!"
                    } else {
                        hud.label.text = "保存失败!"
                    }
                    hud.hide(animated: true, afterDelay: 1.5)
                }
            })
        })
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: { (_) in })
        alertVc.addAction(saveAction)
        alertVc.addAction(cancelAction)
        viewTopVc(responder: self)?.present(alertVc, animated: true, completion: nil)
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imgView.frame.size.height / scale
        zoomRect.size.width  = imgView.frame.size.width  / scale
        let newCenter = imgView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imgView.frame = self.bounds
    }

    func startLoading() {
        self.hud?.isHidden = false
        self.hud?.startAnimating()
    }
    
    func endLoading() {
        self.hud?.startAnimating()
        self.hud?.isHidden = true
    }
 
    //MARK: - ScrollView Delegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imgView
    }
}




