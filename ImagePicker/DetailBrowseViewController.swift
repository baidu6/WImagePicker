//
//  DetailBrowseViewController.swift
//  WImagePicker
//
//  Created by 王云 on 2017/11/30.
//  Copyright © 2017年 王云. All rights reserved.
//

import UIKit

class DetailBrowseViewController: UIViewController {
    
    fileprivate var collectionView: UICollectionView!
    var image: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "查看大图"
        setupUI()
        
    }
    
    func setupUI() {
      
        view.backgroundColor = UIColor.white
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: kScreenWidth, height: kScreenHeight - SafeEdge.top - SafeEdge.bottom)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame: CGRect(x: 0, y: SafeEdge.top, width: kScreenWidth, height: kScreenHeight - SafeEdge.top - SafeEdge.bottom), collectionViewLayout: flowLayout)
        collectionView.register(BrowseCollectionCell.self, forCellWithReuseIdentifier: "BrowseCollectionCellID")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = bgColor
        view.addSubview(collectionView)
    }

}

extension DetailBrowseViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowseCollectionCellID", for: indexPath) as! BrowseCollectionCell
        if let image = image {
            cell.displayData(image: image)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationController?.popViewController(animated: true)
    }
}


class BrowseCollectionCell: UICollectionViewCell {
    
    fileprivate var iconImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.clipsToBounds = true
        contentView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func displayData(image: UIImage) {
        iconImageView.image = image
    }
}
