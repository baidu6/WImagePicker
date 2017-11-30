//
//  ViewController.swift
//  WImagePicker
//
//  Created by 王云 on 2017/11/14.
//  Copyright © 2017年 王云. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var textView: UITextView!
    var btn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        textView = UITextView(frame: CGRect(x: 0, y: 88, width: kScreenWidth, height: 300))
        view.addSubview(textView)
        
        btn = UIButton(frame: CGRect(x: (kScreenWidth - 100) * 0.5, y: 400, width: 100, height: 50))
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = UIColor.orange
        btn.layer.cornerRadius = 6
        btn.layer.masksToBounds = true
        btn.setTitle("选择相册", for: .normal)
        btn.titleLabel?.textAlignment = NSTextAlignment.center
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        btn.addTarget(self, action: #selector(chooseImage), for: UIControlEvents.touchUpInside)
        view.addSubview(btn)
    }
    
    @objc func showImage(noti: Notification) {
        if let images = noti.object as? [UIImage] {
            let attributeString = NSMutableAttributedString()
            for image in images {
                let attachment = NSTextAttachment()
                attachment.image = image
                attributeString.append(NSAttributedString(attachment: attachment))
            }
            textView.attributedText = attributeString
        }
        
    }
    
    @objc func chooseImage() {
        let albumList = AlbumListViewController()
        let nav = UINavigationController(rootViewController: albumList)
        present(nav, animated: true)
        
        albumList.commpleted = {[weak self] images in
            if let images = images {
                let attributeString = NSMutableAttributedString()
                for image in images {
                    let attachment = NSTextAttachment()
                    attachment.image = image
                    attributeString.append(NSAttributedString(attachment: attachment))
                }
                self?.textView.attributedText = attributeString
            }
        }
        
    }
   
}

