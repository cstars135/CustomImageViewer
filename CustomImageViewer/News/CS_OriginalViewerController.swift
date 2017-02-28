//
//  CS_OriginalViewer.swift
//  CustomImageViewer
//
//  Created by Cstars on 2017/1/24.
//  Copyright © 2017年 cstars. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import AlamofireImage
import SnapKit
import Hero
import Photos
import MBProgressHUD

func viewTopVc(responder: UIResponder) -> UIViewController? {
    if let nextResponder = responder.next {
        if nextResponder is UIViewController {
            return nextResponder as? UIViewController
        } else {
            return viewTopVc(responder: nextResponder)
        }
    } else{
        return nil
    }
}

class CS_OriginalViewerController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NVActivityIndicatorViewable {
    var collectionView: UICollectionView?
    let indicatorView = UILabel()
    let saveBtn = UIButton()
    public var curSelectedIndex: Int = 0
    public var thumbnails = [String]()
    public var imgUrls: [String]?
    public var placeHolderImg: UIImage?
    var panGes: UIPanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isHeroEnabled = true
        self.view.backgroundColor = UIColor.black
        
        self.setUpCollectionView()
        self.setUpSaveBtn()
        self.setUpIndicatorView()
        
        view.layoutIfNeeded()
        self.collectionView?.scrollToItem(at: IndexPath(item: curSelectedIndex, section: 0), at: .left, animated: false)
    }
    
    func setUpIndicatorView() {
        self.indicatorView.textColor = UIColor.white
        self.indicatorView.font = UIFont.systemFont(ofSize: 12)
        self.indicatorView.text = "\(self.curSelectedIndex+1)/\(self.thumbnails.count)"
        self.view.addSubview(self.indicatorView)
    }
    
    func setUpSaveBtn() {
        self.saveBtn.addTarget(self, action: #selector(self.saveImg), for: .touchUpInside)
        self.saveBtn.setTitle("保存", for: .normal)
        self.saveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.saveBtn.setTitleColor(UIColor.white, for: .normal)
        self.saveBtn.setBackgroundImage(UIImage.pixel(ofColor: UIColor(white: 0, alpha: 0.5)), for: .normal)
        self.view.addSubview(self.saveBtn)
    }
    
    func saveImg() {
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status != .authorized {
                    DispatchQueue.main.async {
                        let authoAlertVc = UIAlertController(title: "请到设置开启相册访问权限", message: nil, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "好", style: .default, handler: nil)
                        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
                        authoAlertVc.addAction(okAction)
                        authoAlertVc.addAction(cancelAction)
                        self.present(authoAlertVc, animated: true, completion: nil)
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
    
    func showSaveAlert() {
        let alertVc = UIAlertController(title: "要保存图片吗?", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "确定", style: .default, handler: { (saveAction) in
            
            PHPhotoLibrary.shared().performChanges({ [weak self] in
                let img = (self?.collectionView?.visibleCells.first as! CS_OriginalCell).imgView.image
                PHAssetChangeRequest.creationRequestForAsset(from: img!)
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
        self.present(alertVc, animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var frame = self.view.bounds
        frame.size.width += 10
        self.collectionView?.frame = frame
        
        self.indicatorView.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(15)
            maker.centerX.equalToSuperview()
        }
        
        self.saveBtn.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(15)
            maker.trailing.equalToSuperview().offset(-15)
            maker.size.equalTo(CGSize(width: 50, height: 30))
        }
    }

    func setUpCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        let w = UIScreen.main.bounds.size.width
        let h = UIScreen.main.bounds.size.height
        
        flowLayout.itemSize = CGSize(width: w, height: h)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.16, alpha: 1)
        collectionView?.isPagingEnabled = true
        collectionView?.register(UINib(nibName: "CS_OriginalCell", bundle: nil), forCellWithReuseIdentifier: "CS_OriginalCell")
        self.view.addSubview(collectionView!)
        
        //Add Pan Gesture
        let panGes = UIPanGestureRecognizer(target: self, action: #selector(self.pan(panGes:)))
        self.panGes = panGes
        panGes.delegate = self
        self.collectionView?.addGestureRecognizer(panGes)
    }    
    
    func pan(panGes: UIPanGestureRecognizer) {
        let translation = panGes.translation(in: nil)
        let progress = translation.y / 2 / collectionView!.bounds.height
        switch panGes.state {
        case .began:
            self.dismiss(animated: true, completion: nil)
        case .changed:
            Hero.shared.update(progress: Double(progress))
            if let cell = collectionView?.visibleCells[0]  as? CS_OriginalCell{
                let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
                Hero.shared.apply(modifiers: [.position(currentPos)], to: cell.imgView)
            }
        default:
            if progress + panGes.velocity(in: nil).y / collectionView!.bounds.height > 0.3{
                Hero.shared.end()
                print("hero---end")
            } else {
                print("hero--cancel")
                Hero.shared.cancel()
            }
        }
    }
    
   //MARK: - Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CS_OriginalCell", for: indexPath) as! CS_OriginalCell
        cell.index = indexPath.row
        if let imgUrl = URL(string: self.thumbnails[indexPath.item]) {
            cell.imgView.af_setImage(withURL: imgUrl, placeholderImage: self.placeHolderImg)
        }
        cell.dismissAction = { [weak self] in
            let visableIndex = (self?.collectionView?.indexPathsForVisibleItems.first)!
            NotificationCenter.default.post(Notification(name: Notification.Name("backFromOriginViewer"), object: self, userInfo: ["index": visableIndex.item]))
            self?.dismiss(animated: true, completion: nil)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let originalCell = cell as! CS_OriginalCell
        
       if let imgUrls = self.imgUrls {
            if let imgUrl = URL(string: imgUrls[indexPath.item]) {
                originalCell.imgView.af_setImage(withURL: imgUrl, progress: { [weak originalCell](progress) in
                    if let isAnimating = originalCell?.hud?.isAnimating, isAnimating == false {
                        originalCell?.hud?.startAnimating()
                    }
                }, completion: { [weak originalCell](response) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.25, execute: {
                        if let isAnimating = originalCell?.hud?.isAnimating, isAnimating == true {
                            originalCell?.endLoading()
                        }
                    })
                })
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        let page = Int(contentOffsetX / scrollView.bounds.size.width)
        self.indicatorView.text = "\(page+1)/\(self.thumbnails.count)"
    }
}


extension CS_OriginalViewerController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let cell = collectionView?.visibleCells[0] as? CS_OriginalCell,
            cell.scrollView.zoomScale == 1 {
            let v = panGes!.velocity(in: nil)
            return v.y > abs(v.x)
        }
        return false
    }
}
