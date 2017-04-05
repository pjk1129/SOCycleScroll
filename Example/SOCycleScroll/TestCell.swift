//
//  TestCell.swift
//  SOCycleScroll
//
//  Created by JK.PENG on 2017/4/5.
//  Copyright © 2017年 xxxx. All rights reserved.
//

import UIKit

class TestCell: UICollectionViewCell {
    // MARK:- 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        imageView.backgroundColor = UIColor.clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(imageView)
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-2-[imageView]-2-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView" : imageView]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[imageView]-2-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["imageView" : imageView]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var imageView: UIImageView!
}
