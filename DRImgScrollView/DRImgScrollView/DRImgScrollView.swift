//
//  DRImgScrollView.swift
//  DRImgScrollView
//
//  Created by xqzh on 16/6/24.
//  Copyright © 2016年 xqzh. All rights reserved.
//

import UIKit

// 定义闭包
typealias SendValueClosure = (index:CGFloat) -> Void

let duration:CGFloat = 2.0 // 自动滚动时间间隔

class DRImgScrollView: UIView {

    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    var Num:Int = 0
    
    
    var imgArr:NSMutableArray?
    
    var timer:NSTimer?
    
    // 声明一个闭包
    var sendValue:SendValueClosure?
    
    var scrollView:UIScrollView
    
    var pageControl:UIPageControl
    
    override init(frame: CGRect) {
        
        scrollView = UIScrollView(frame: frame)
        pageControl = UIPageControl(frame: CGRectMake(0, 180, frame.size.width, 10))
        
        super.init(frame: frame)
    }
    
    convenience init(frame:CGRect, imgArray:NSArray) {
        
        
        self.init(frame: frame)
        
        width = frame.size.width
        height = frame.size.height
        
        let count = imgArray.count
        Num = count
        
        scrollView.contentSize = CGSizeMake(frame.size.width * 3, 0)
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        
        scrollView.showsHorizontalScrollIndicator = false
        
        imgArr = NSMutableArray(array: imgArray)
        
        // 首页
        var imgView = UIImageView(image: imgArray[count - 1] as? UIImage)
        imgView.frame = CGRectMake(0, 0, width, height)
        scrollView.addSubview(imgView)
        
        // 正式页
        for i in 0...1 {
            imgView = UIImageView(image: imgArray[i] as? UIImage)
            imgView.frame = CGRectMake(CGFloat(i + 1) * width, 0, width, height)
            scrollView.addSubview(imgView)
        }
        
        scrollView.setContentOffset(CGPointMake(width, 0), animated: true)
        
        self.addSubview(scrollView)
        
        pageControl.numberOfPages = count
        pageControl.currentPage = 0
        self.addSubview(pageControl)
        
        
        // 时间触发器
        timer = NSTimer.scheduledTimerWithTimeInterval(Double(duration), target: self, selector: #selector(DRImgScrollView.run), userInfo: nil, repeats: true)
//        self.performSelector(#selector(DRImgScrollView.fire), withObject: nil, afterDelay: 5)
        timer?.fire()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 时间器触发动作
    func run() -> Void {
        var index:Int = pageControl.currentPage + 1
        index += 1
        print(index)

        UIView.animateWithDuration(1) { 
            self.scrollView.setContentOffset(CGPointMake(CGFloat(2) * self.width, 0), animated: false)
        }
        
        scrollViewDidEndDecelerating(scrollView)

    }
    
    // 延时首尾切换
    func delay() -> Void {
        scrollView.setContentOffset(CGPointMake(CGFloat(1) * width, 0), animated: false)
    }
    
    // 延时继续时间器
    func fire() -> Void {
        timer?.resumeTimer()
    }

}

// DRImgScrollerView延展，遵循代理
extension DRImgScrollView : UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if scrollView.decelerating {
            scrollView.scrollEnabled = false
        }
        else {
            scrollView.scrollEnabled = true
        }
        
        
        if scrollView.contentOffset.x == 2 * width {
            // 正向移动
            var num = pageControl.currentPage
            num += 1
            
            pageControl.currentPage = num % Num
        
        }
        else if scrollView.contentOffset.x == 0 {

            var num = pageControl.currentPage
            num -= 1
        
        
            num = num < 0 ? Num - 1 : num
            pageControl.currentPage = num % Num
        }
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        // 暂停timer
        timer?.pauseTimer()
        
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        scrollView.scrollEnabled = true
        
        // 切换scrollView至中间位置
        scrollView.contentOffset = CGPointMake(width, 0)
        
        // 前页位置换图
        let i = (pageControl.currentPage - 1 < 0) ? (Num - 1) : (pageControl.currentPage - 1)
        let img2:UIImageView = scrollView.subviews[0] as! UIImageView
        img2.image = imgArr![i] as? UIImage
        
        // 中间位置换图
        let img:UIImageView = scrollView.subviews[1] as! UIImageView
        img.image = imgArr![pageControl.currentPage] as? UIImage
        
        // 末尾位置换图
        let j = (pageControl.currentPage + 1 >= Num) ? 0 : (pageControl.currentPage + 1)
        let img1:UIImageView = scrollView.subviews[2] as! UIImageView
        img1.image = imgArr![j] as? UIImage
        
        // 闭包传值
        sendValue?(index: CGFloat(pageControl.currentPage))
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 开始timer
        self.performSelector(#selector(DRImgScrollView.fire), withObject: nil, afterDelay: Double(duration))
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        
    }
    
    
}

// 扩展NSTimer方法
extension NSTimer {
    
    func pauseTimer() -> Void {
        if !self.valid {
            return
        }
        
        self.fireDate = NSDate.distantFuture()
    }
    
    func resumeTimer() -> Void {
        if !self.valid {
            return
        }
        
        self.fireDate = NSDate()
    }
}

