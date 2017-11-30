//
//  ImagePickerViewController.swift
//  WImagePicker
//
//  Created by 王云 on 2017/11/14.
//  Copyright © 2017年 王云. All rights reserved.
//

import UIKit
import Photos

typealias OnCommpletedHandler = ([UIImage]?) -> Void

let bgColor = UIColor.black.withAlphaComponent(0.7)
let kScreenWidth = UIScreen.main.bounds.size.width
let kScreenHeight = UIScreen.main.bounds.size.height
let IPhoneX = UIScreen.main.bounds.size == CGSize(width: 375, height: 812)
let SafeEdge = UIEdgeInsets(top: IPhoneX ? 88 : 64, left: 0, bottom: IPhoneX ? 34 : 0, right: 0)
class ImagePickerViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var bottomView: AlbumBottomView!
    
    var albumItem: AlbumItem!
    var itemWidth: CGFloat!
    let cols: CGFloat = 4
    let margin = 5 * k_FitWidth
    
    typealias CancelBtnDidClick = () -> Void
    var cancelClick: CancelBtnDidClick?
    
    var completed: OnCommpletedHandler?
    
    let maxCheckCount: Int = 3
    var checkedAssets: [PHAsset] = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupCollectionView()
    }
    
    func setupNav() {
        view.backgroundColor = UIColor.white
        self.navigationItem.title = albumItem.title
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
    }
    
    @objc func cancel() {
        self.cancelClick?()
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupCollectionView() {
        
        let flowLayout = UICollectionViewFlowLayout()
        itemWidth = (kScreenWidth - (cols + 1) * margin) / cols
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.register(AlbumItemCell.self, forCellWithReuseIdentifier: "PickerCellID")
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.white
        
        bottomView = AlbumBottomView()
        view.addSubview(bottomView)
        
        collectionView.snp.makeConstraints { (make) in
            make.left.right.equalTo(view)
            make.top.equalToSuperview().offset(SafeEdge.top)
            make.bottom.equalToSuperview().offset(-SafeEdge.bottom - 44)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-SafeEdge.bottom)
            make.height.equalTo(44)
        }
        
        bottomView.doneBtnClick = {[weak self] in
            self?.done()
        }
    }
    
    func done() {
        cancel()
        var imagesArr = [UIImage]()
        for asset in self.checkedAssets {
            ImagePickerManager.getImageFromAsset(asset: asset, finished: { (image) in
                if let image = image {
                    imagesArr.append(image)
                }
            })
        }
        completed?(imagesArr)
    }
    
    func addAssets(asset: PHAsset, btn: UIButton) {
        if self.checkedAssets.contains(asset) == false {
            
            if self.checkedAssets.count >= maxCheckCount {
                let alert = UIAlertController(title: "提醒", message: "最多可以选择\(maxCheckCount)张图片", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "确定", style: .default, handler: nil)
                alert.addAction(confirm)
                self.navigationController?.present(alert, animated: true, completion: nil)
                return
            }
            self.checkedAssets.append(asset)
            btn.isSelected = !btn.isSelected
        }
        bottomView.doneBtn.isEnabled = self.checkedAssets.count > 0
    }
    
    func deleteAssets(asset: PHAsset, btn: UIButton) {
        if self.checkedAssets.contains(asset) == true {
            guard let index = self.checkedAssets.index(of: asset) else {return}
            self.checkedAssets.remove(at: index)
            btn.isSelected = !btn.isSelected
        }
        bottomView.doneBtn.isEnabled = self.checkedAssets.count > 0
    }

}

extension ImagePickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumItem.fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickerCellID", for: indexPath) as! AlbumItemCell
        let asset = self.albumItem.fetchResult[indexPath.row]
        cell.displayData(asset: asset)
        cell.checkClick = {[weak self] btn in
            
            if btn.isSelected == false {
                self?.addAssets(asset: asset, btn: btn)
            }else {
                self?.deleteAssets(asset: asset, btn: btn)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.albumItem.fetchResult[indexPath.row]
        let browseVC = DetailBrowseViewController()
        //获取原图
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFill, options: nil) { (image, _) in
            if let image = image {
                browseVC.image = image
                self.navigationController?.pushViewController(browseVC, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return margin
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
}

class AlbumItemCell: UICollectionViewCell {
    var iconView: UIImageView!
    var imageManager = PHCachingImageManager()
    var asset: PHAsset!
    fileprivate var checkBtn: UIButton!
    
    typealias CheckBtnDidClick = (_ btn: UIButton) -> Void
    var checkClick: CheckBtnDidClick?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        iconView = UIImageView()
        iconView.contentMode = .scaleAspectFill
        iconView.clipsToBounds = true
        contentView.addSubview(iconView)
        
        checkBtn = UIButton()
        checkBtn.setImage(UIImage(named: "check"), for: .normal)
        checkBtn.setImage(UIImage(named: "checked"), for: .selected)
        checkBtn.addTarget(self, action: #selector(check(btn:)), for: .touchUpInside)
        addSubview(checkBtn)
        
        iconView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        checkBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(20)
            make.top.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    @objc func check(btn: UIButton) {
        checkClick?(btn)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func displayData(asset: PHAsset) {
        
        self.imageManager.requestImage(for: asset, targetSize: self.frame.size, contentMode: PHImageContentMode.aspectFill, options: nil) { [weak self](image, info) in
        if let image = image {
                self?.iconView.image = image
            }
        }
    }
}

class AlbumBottomView: UIView {
    typealias SimpleCallBack = () -> Void
    var doneBtnClick: SimpleCallBack?
    
    var doneBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = bgColor
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        doneBtn = UIButton()
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        doneBtn.setTitleColor(UIColor.lightGray, for: .disabled)
        doneBtn.setTitleColor(UIColor.white, for: .normal)
        doneBtn.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        doneBtn.layer.cornerRadius = 5
        doneBtn.layer.masksToBounds = true
        doneBtn.isEnabled = false
        doneBtn.addTarget(self, action: #selector(done), for: UIControlEvents.touchUpInside)
        addSubview(doneBtn)
        
        doneBtn.snp.makeConstraints { (make) in
            make.width.equalTo(60)
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc func done() {
        self.doneBtnClick?()
    }
}

