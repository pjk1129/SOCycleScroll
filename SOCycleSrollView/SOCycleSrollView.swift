//
//  SOCycleSrollView.swift
//  SOCycleScroll
//
//  Created by JK.PENG on 2017/4/1.
//  Copyright © 2017年 xxxx. All rights reserved.
//

import UIKit

/*
 None: only scroll manually
 Auto: scoll automatically without cyclic, when scroll to the end, it will scroll back to the first item
 Cyclically: scroll manually, and when scroll to the end, it will still scroll to the next -- the first item
 AutoCyclically: the same as the BMBannerScrollTypeCyclically, and add the automatic feature.
 */
public enum SOScrollType : Int {
    case None
    case Auto
    case Cyclically
    case AutoCyclically
}

public protocol SOCycleSrollViewDataSource {
    func numberOfItemsInCollectionView(_ cycleSrollView: SOCycleSrollView) -> Int
    func collectionView(_ cycleSrollView: SOCycleSrollView, cellForItemAt indexPath: Int) -> UICollectionViewCell
}

public protocol SOCycleSrollViewDelegate : NSObjectProtocol  {
    func collectionView(_ cycleSrollView: SOCycleSrollView, didSelectItemAt index: Int)
    func collectionView(_ cycleSrollView: SOCycleSrollView, didScrollTo index: Int)
}

//MARK: SOCycleSrollViewDelegate默认实现
extension SOCycleSrollViewDelegate {
    func collectionView(_ cycleSrollView: SOCycleSrollView, didSelectItemAt index: Int){
    }
    
    func collectionView(_ cycleSrollView: SOCycleSrollView, didScrollTo index: Int){
    }
}

open class SOCycleSrollView: UIView {
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    //MARK: 初始化
    public init(_ frame: CGRect, scrollDirection direction: UICollectionViewScrollDirection){
        super.init(frame: frame)
        scrollDirection = direction
        setupCollectionView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: 属性
    open var delegate: SOCycleSrollViewDelegate?
    open var dataSource: SOCycleSrollViewDataSource?
    open var autoScrollTimeInterval: TimeInterval = 3.0
    
    open var scrollEnabled: Bool = true {
        didSet{
            self.collectionView.isScrollEnabled = scrollEnabled
        }
    }
    
    open var scrollType: SOScrollType = SOScrollType.None {
        didSet{
            switch scrollType {
            case .None:
                cycleScrollEnabled = false
                autoScrollFlag = false
                break
            case .Auto:
                cycleScrollEnabled = false
                autoScrollFlag = true
                break
            case .Cyclically:
                cycleScrollEnabled = true
                autoScrollFlag = false
                if self.scrollDirection == .horizontal  {
                    self.collectionView.contentOffset = CGPoint(x: self.bounds.width, y: 0)
                }else{
                    self.collectionView.contentOffset = CGPoint(x: 0, y: self.bounds.height)
                }
                break
            case .AutoCyclically:
                cycleScrollEnabled = true
                autoScrollFlag = true
                if self.scrollDirection == .horizontal  {
                    self.collectionView.contentOffset = CGPoint(x: self.bounds.width, y: 0)
                }else{
                    self.collectionView.contentOffset = CGPoint(x: 0, y: self.bounds.height)
                }
                break
            }
        }
    }
    
    //MARK: 私有属性
    fileprivate var autoScrollFlag: Bool = false
    fileprivate var cycleScrollEnabled: Bool = false
    
    fileprivate var numberOfItems:Int = 0
    fileprivate var numberOfRecources:Int = 0
    fileprivate var item:Int = 0
    fileprivate var currentPage:Int = 0
    
    fileprivate var collectionView: UICollectionView!
    fileprivate var scrollDirection: UICollectionViewScrollDirection = .vertical

    
    private func setupCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.scrollDirection = scrollDirection
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = self.scrollEnabled
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(collectionView)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView" : collectionView]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["collectionView" : collectionView]))
    }
    
}

//MARK: open public method
extension SOCycleSrollView{
    open func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String){
        self.collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    open func dequeueReusableCell(withReuseIdentifier identifier: String) -> UICollectionViewCell{
        let indexPath = IndexPath(item: self.item, section: 0)
        return self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    open func reloadData(){
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        DispatchQueue.main.async {
            self.numberOfRecources = (self.dataSource?.numberOfItemsInCollectionView(self))!
            self.collectionView.reloadData()
            self.scrollToOriginPositon()
            self.prepareAutoScrollIfNeeded()
        }
    }
    
    open func stopAutoScroll() {
        if autoScrollFlag {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
    }
    
    open func resumeAutoScroll() {
        if autoScrollFlag {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(autoScrollCollectionView), with: self, afterDelay: autoScrollTimeInterval)
        }
    }
}

//MARK: priviate method
extension SOCycleSrollView{
    @objc fileprivate func autoScrollCollectionView() {
        if autoScrollFlag {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            let page = self.scrollCurrentPage()
            self.scrollToPage(to: page+1, animated: true)
            self.prepareAutoScrollIfNeeded()
        }
    }
    
    fileprivate func scrollToPage(to page: Int, animated: Bool){
        var targetPage = page
        if self.scrollType == .Auto {
            if targetPage >= self.numberOfItems {
                targetPage = 0
            }
        }
        if self.numberOfItems <= 1 || targetPage > self.numberOfItems-1 {
            return
        }
        
        let path = IndexPath(item: targetPage, section: 0)
        self.collectionView.scrollToItem(at: path, at: UICollectionViewScrollPosition.init(rawValue: 0), animated: true)
        
    }
    
    fileprivate func didScrollToPage(to page: Int){
        if !cycleScrollEnabled {
            self.currentPage = page
            return
        }
        
        if self.numberOfItems <= 1 {
            return
        }
        
        if page>=1 && page<self.numberOfItems-1{
            self.currentPage = page - 1
        }else if (page >= self.numberOfItems-1) {
            self.currentPage = 0
            let path = IndexPath(item: self.currentPage+1, section: 0)
            self.collectionView.scrollToItem(at: path, at: UICollectionViewScrollPosition.init(rawValue: 0), animated: false)
        }else if (page < 1) {
            self.currentPage = self.numberOfItems - 2
            let path = IndexPath(item: self.currentPage, section: 0)
            self.collectionView.scrollToItem(at: path, at: UICollectionViewScrollPosition.init(rawValue: 0), animated: false)
        }
        
    }
    
    fileprivate func itemFromIndexPath(_ indexPath:IndexPath) -> Int{
        if self.numberOfItems <= 1 {
            return indexPath.item
        }
        
        var item = 0
        if self.scrollType == .None || self.scrollType == .Auto {
            item = indexPath.item
        }else if self.scrollType == .Cyclically || self.scrollType == .AutoCyclically {
            if indexPath.item <= 0 {
                item = self.numberOfItems - 3
            }else if indexPath.item > 0 && indexPath.item < self.numberOfItems-1 {
                item = indexPath.item - 1
            }else if indexPath.item >= indexPath.row - 1 {
                item = 0
            }
        }
        return item
    }
    
    fileprivate func prepareAutoScrollIfNeeded() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if autoScrollFlag {
            self.perform(#selector(autoScrollCollectionView), with: self, afterDelay: autoScrollTimeInterval)
        }
    }
    
    fileprivate func scrollToOriginPositon() {
        self.currentPage = 0
        if cycleScrollEnabled && self.numberOfRecources > 1 {
            let path = IndexPath(item: 1, section: 0)
            self.collectionView.scrollToItem(at: path, at: UICollectionViewScrollPosition.init(rawValue: 0), animated: false)
        }else if self.numberOfRecources == 1 {
            let path = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: path, at: UICollectionViewScrollPosition.init(rawValue: 0), animated: false)
        }
    }
    
    fileprivate func scrollCurrentPage() -> Int {
        if self.scrollDirection == .horizontal {
            let offsetX = self.collectionView.contentOffset.x
            let itemWidth = self.collectionView.frame.width
            if offsetX >= 0 {
                return Int(offsetX)/Int(itemWidth)
            }
        }else{
            let offsetY = self.collectionView.contentOffset.y
            let itemHeight = self.collectionView.frame.height
            if offsetY >= 0 {
                return Int(offsetY)/Int(itemHeight)
            }
        }
        return 0
    }
}

//MARK:- UICollectionView 协议方法实现
extension SOCycleSrollView: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: self.bounds.width, height: self.bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        self.numberOfRecources = (self.dataSource?.numberOfItemsInCollectionView(self))!
        self.numberOfItems = self.numberOfRecources
        if self.numberOfItems <= 1 {
            return self.numberOfItems
        }
        
        if self.scrollType == .Cyclically || self.scrollType == .AutoCyclically {
            self.numberOfItems += 2
        }
        return self.numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        self.item = indexPath.row
        let item = self.itemFromIndexPath(indexPath)
        let cell = self.dataSource?.collectionView(self, cellForItemAt: item)
        return cell!
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        let item = self.itemFromIndexPath(indexPath)
        self.delegate?.collectionView(self, didSelectItemAt: item)
    }
    
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let page = self.scrollCurrentPage()
        self.didScrollToPage(to: page)
        self.delegate?.collectionView(self, didScrollTo: page)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = self.scrollCurrentPage()
        self.didScrollToPage(to: page)
        self.prepareAutoScrollIfNeeded()
        self.delegate?.collectionView(self, didScrollTo: page)
    }
    
}
