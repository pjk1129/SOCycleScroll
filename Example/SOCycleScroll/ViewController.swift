//
//  ViewController.swift
//  SOCycleScroll
//
//  Created by JK.PENG on 2017/4/1.
//  Copyright © 2017年 xxxx. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCycleSrollView()
        self.scrollView.reloadData()        
    }

    let kCycleScrollViewReuseIdentifer = "kCycleScrollViewReuseIdentifer"
    var scrollView:SOCycleSrollView!
    var data = ["https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1491382540809&di=e1cceb0b11c81988d4f419983adfa9df&imgtype=0&src=http%3A%2F%2Fattachments.gfan.com%2Fforum%2Fattachments2%2F201304%2F10%2F104028xfxsklfilosaa1jh.jpg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1491382540806&di=691ac2b72f586b4e9edd2f33d6277edd&imgtype=0&src=http%3A%2F%2Fsoft.luobou.com%2Fbizhi%2Ffengjing%2F1473141512150.jpg","https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=2373549711,3835726044&fm=23&gp=0.jpg","https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1491382745157&di=b2f9ca30f3982ceebe6ac22bad13b372&imgtype=0&src=http%3A%2F%2Fpic.58pic.com%2F58pic%2F11%2F16%2F02%2F32H58PICPre.jpg"]
    
    
    private func setupCycleSrollView(){
        scrollView = SOCycleSrollView(CGRect.zero, scrollDirection: .horizontal)
        scrollView.backgroundColor = UIColor.orange
        scrollView.delegate = self
        scrollView.dataSource = self
        scrollView.scrollType = .AutoCyclically
        scrollView.register(TestCell.self, forCellWithReuseIdentifier: kCycleScrollViewReuseIdentifer)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[scrollView]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView" : scrollView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-100-[scrollView(==204)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["scrollView" : scrollView]))
    }

}

extension ViewController: SOCycleSrollViewDelegate, SOCycleSrollViewDataSource {
    
    func numberOfItemsInCollectionView(_ cycleSrollView: SOCycleSrollView) -> Int {
        return self.data.count
    }
    
    func collectionView(_ cycleSrollView: SOCycleSrollView, cellForItemAt indexPath: Int) -> UICollectionViewCell {
        let cell = cycleSrollView.dequeueReusableCell(withReuseIdentifier: kCycleScrollViewReuseIdentifer) as! TestCell
        let url = URL(string: self.data[indexPath])
        cell.imageView.kf.setImage(with: url)
        return cell
    }
    
    func collectionView(_ cycleSrollView: SOCycleSrollView, didSelectItemAt index: Int) {
        print(index)
    }
}

