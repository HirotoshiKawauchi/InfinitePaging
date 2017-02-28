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
    @IBOutlet weak var pagingScrollView: UIScrollView!
    
    var contentViews: [ContentView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
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
        pagingScrollView.contentOffset.x = UIScreen.main.bounds.width
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
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === pagingScrollView {
            guard scrollView.contentSize != .zero else {
                return
            }
            
            // faking infinite scrolling
            recenterPagingScrollView()
        }
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

