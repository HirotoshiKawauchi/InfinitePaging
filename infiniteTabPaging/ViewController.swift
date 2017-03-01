//
//  ViewController.swift
//  infiniteTabPaging
//
//  Created by HIROTOSHI KAWAUCHI on 2017/02/24.
//  Copyright © 2017年 HIROTOSHI KAWAUCHI. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tabScrollView: TabScrollView!
    @IBOutlet weak var selectionTabScrollView: TabScrollView!
    @IBOutlet weak var pagingScrollView: UIScrollView!
    
    var contentViews: [ContentView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        setupSelectionMask()

        setup()
    }
    
    private func setup() {
        let titles: [String] = ["ねずみ", "うし", "とら", "う",
                                "たつ", "へび", "うま", "ひつじ",
                                "さる", "とり", "いぬ", "いのしし"]
        for title in titles {
            let contentView = ContentView.view()
            contentView.frame = view.bounds
            contentView.setUp(title: title)
            contentViews.append(contentView)
        }
        
        selectedView(view: contentViews.first!, animated: true)
        
        tabScrollView.setup(pagingViewList: contentViews)
        selectionTabScrollView.setup(pagingViewList: contentViews, isSelection: true)
        pagingScrollView.contentOffset.x = UIScreen.main.bounds.width
        
        refreshSelectionMask()
        scrollToHorizontalCenter(index: contentViews.count)
    }
    
    enum Position: Int {
        case Left
        case Center
        case Right
        
        func inverse() -> Position {
            switch self {
            case .Left: return .Right
            case .Center: return .Center
            case .Right: return .Left
            }
        }
    }
    
    func viewAt(position: Position) -> ContentView? {
        var view: UIView?
        if position.rawValue < pagingScrollView.subviews.count {
            view = pagingScrollView.subviews[position.rawValue].subviews.last
        }
        
        if let view = view {
            for contentView in contentViews {
                if contentView === view {
                    return contentView
                }
            }
        }
        
        return nil
    }
    
    func set(view: ContentView, at position: Position, newIndex: Int? = nil) {
        if let currentView = viewAt(position: position),
            let selectedView = viewAt(position: .Center),
            let currentIndex = contentViews.index(of: currentView) {
            
            let index = newIndex ?? contentViews.index(of: position == .Center ? view : selectedView)!
            let minIndex = min(currentIndex, index)
            let maxIndex = max(currentIndex, index)
            if min(abs(minIndex - maxIndex), abs(minIndex + contentViews.count - maxIndex) as Int) > 1 {
                currentView.removeFromSuperview()
            }
        }
        
        pagingScrollView.subviews[position.rawValue].addSubview(view)
    }
    
    func selectedView(view: ContentView, animated: Bool) {
        guard let index = contentViews.index(of: view) else {
            return
        }
        
        set(view: view, at: .Center)
        set(view: contentViews[(index - 1 + contentViews.count) % contentViews.count], at: .Left)
        set(view: contentViews[(index + 1) % contentViews.count], at: .Right)
    }
    
    func removeViewAt(position: Position) {
        guard let view = viewAt(position: position) else {
            return
        }
        
        view.removeFromSuperview()
    }
    
    var selectedView: ContentView? {
        return viewAt(position: .Center)
    }
    
    weak var selectionMaskLayer: CAShapeLayer!
    let selectionMaskCornerRadius: CGFloat = 40.0
    func setupSelectionMask() {
        let maskLayer = CAShapeLayer()
        maskLayer.frame.size.height = selectionTabScrollView.bounds.height
        let path: CGPath = UIBezierPath(roundedRect: maskLayer.bounds, cornerRadius: selectionMaskCornerRadius).cgPath
        maskLayer.path = path
        selectionTabScrollView.layer.mask = maskLayer
        selectionMaskLayer = maskLayer
    }
    
    func refreshSelectionMask() {
        guard let selectedView = selectedView,
        let selectedIndex = contentViews.index(of: selectedView),
        let nextView = viewAt(position: pagingScrollView.contentOffset.x < pagingScrollView.bounds.width ? .Left : .Right),
        let nextIndex = contentViews.index(of: nextView) else {
            return
        }
        
        let percent = abs(pagingScrollView.contentOffset.x - pagingScrollView.bounds.width) / pagingScrollView.bounds.width
        let tabViews = tabScrollView.tabViews
        let selectedTab = tabViews[selectedIndex]
        let nextTab = tabViews[nextIndex]
        
        let width = selectedTab.bounds.width * (1 - percent) + nextTab.bounds.width * percent
        let tabY = floor((tabScrollView.frame.height - (selectedTab.bounds.height - 10)) / 2)
        let roundRect = CGRect(x: tabScrollView.visibleFrame.midX - (width / 2),
                               y: tabY,
                               width: width,
                               height: selectedTab.bounds.height - 10)
        selectionMaskLayer.path = UIBezierPath(roundedRect: roundRect, cornerRadius: selectionMaskCornerRadius).cgPath
    }
    
    var centerTabIndex: Int = 0
    func scrollToHorizontalCenter(index: Int, animated: Bool = false) {
        let centeringTab = tabScrollView.tabViews[index]
        var centeringTabOffset = tabScrollView.visibleFrame.minX - (tabScrollView.visibleFrame.midX - centeringTab.frame.midX)
        
        centerTabIndex = index
        if centeringTabOffset < 0.0 {
            tabScrollView.contentOffset.x += tabScrollView.tabItemWidth
            centeringTabOffset += tabScrollView.tabItemWidth
            centerTabIndex += contentViews.count
            refreshSelectedMaskFixerdToCenter()
        } else if centeringTabOffset > tabScrollView.tabItemWidth * 2.0 {
            tabScrollView.contentOffset.x -= tabScrollView.tabItemWidth
            centerTabIndex -= contentViews.count
            refreshSelectedMaskFixerdToCenter()
        }
        
        tabScrollView.setContentOffset(CGPoint(x: centeringTabOffset, y: tabScrollView.contentOffset.y), animated: animated)
    }
    
    func refreshSelectedMaskFixerdToCenter() {
        let tabViews = tabScrollView.tabViews
        let centerTab = tabViews[centerTabIndex]
        let tabY = floor((tabScrollView.frame.height - centerTab.bounds.height - 10) / 2)
        let roundRect = CGRect(x: tabScrollView.visibleFrame.midX - (centerTab.bounds.height / 2),
                               y: tabY,
                               width: centerTab.bounds.width,
                               height: centerTab.bounds.height / 2)
        selectionMaskLayer.path = UIBezierPath(roundedRect: roundRect, cornerRadius: selectionMaskCornerRadius).cgPath
    }
    
    func trackingTabScrollView() {
        let position: Position = pagingScrollView.contentOffset.x < pagingScrollView.bounds.width ? .Left : .Right
        guard let selectedView = selectedView,
            let selectedTab = findMostCenterTabIndexForTitle(title: selectedView.tabTitle ?? ""),
            let nextView = viewAt(position: position),
            let nextTab = findMostCenterTabIndexForTitle(title: nextView.tabTitle ?? "") else {
                return
        }
        
        let tabCenterInterval = selectedTab.bounds.midX + nextTab.bounds.midX
        let percent: CGFloat = ((abs(pagingScrollView.contentOffset.x - pagingScrollView.bounds.width)) / pagingScrollView.bounds.width)
        let moveValueRight = nextTab.frame.midX - (tabScrollView.visibleFrame.midX + (tabCenterInterval * (1.0 - percent)))
        let moveValueLeft = (tabScrollView.visibleFrame.midX - (tabCenterInterval * (1.0 - percent))) - nextTab.frame.midX
        if position == .Left {
            tabScrollView.contentOffset.x -= moveValueLeft
        } else {
            tabScrollView.contentOffset.x += moveValueRight
        }
    }
    
    
    var sortedNearerCenterTab: [TabView]? {
        let tabs = tabScrollView.tabViews
        if tabs.isEmpty {
            return nil
        }
        
        return tabs.sorted(by: { (tab1, tab2) -> Bool in
            abs(tabScrollView.visibleFrame.midX - tab1.frame.midX) < abs(tabScrollView.visibleFrame.midX - tab2.frame.midX)
        })
    }
    
    func findMostCenterTabIndexForTitle(title: String) -> TabView? {
        return sortedNearerCenterTab?.filter({ $0.titleLabel.text == title }).first
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === pagingScrollView {
            guard scrollView.contentSize != .zero else {
                return
            }
            
            trackingTabScrollView()
            
            // faking infinite scrolling
            recenterPagingScrollView()
        } else if scrollView === tabScrollView {
            if scrollView.contentOffset.x < 0.0 {
                tabScrollView.contentOffset.x = tabScrollView.tabItemWidth
                centerTabIndex = (centerTabIndex % contentViews.count) + contentViews.count
            } else if scrollView.contentOffset.x > tabScrollView.tabItemWidth * 2.0 {
                tabScrollView.contentOffset.x = tabScrollView.tabItemWidth
                centerTabIndex = (centerTabIndex % contentViews.count) + contentViews.count
            }
        }
        
        selectionTabScrollView.contentOffset = tabScrollView.contentOffset
        refreshSelectionMask()
    }
    
    private func recenterPagingScrollView() {
        var position = Position.Center
        if pagingScrollView.contentOffset.x <= 0 {
            position = .Left
        } else if pagingScrollView.contentOffset.x >= 2 * pagingScrollView.bounds.width {
            position = .Right
        }
        
        guard position != .Center else {
            return
        }
        
        guard let view = viewAt(position: position) else {
            return
        }
        
        removeViewAt(position: position.inverse())
        selectedView(view: view, animated: true)
        pagingScrollView.contentOffset.x += (position == .Left ? 1 : -1) * pagingScrollView.bounds.width
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView === pagingScrollView {
            let roundedValue = round(scrollView.contentOffset.x / scrollView.bounds.width) * scrollView.bounds.width
            if scrollView.contentOffset.x != roundedValue {
                scrollView.contentOffset.x = round(scrollView.contentOffset.x / scrollView.bounds.width) * scrollView.bounds.width
            }
        }
    }
}

