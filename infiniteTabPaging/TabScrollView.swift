//
//  TabScrollView.swift
//  infiniteTabPaging
//
//  Created by HIROTOSHI KAWAUCHI on 2017/02/24.
//  Copyright © 2017年 HIROTOSHI KAWAUCHI. All rights reserved.
//

import UIKit

class TabScrollView: UIScrollView {
    let contentView: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 0.0, height: 45.0))
    
    var tabItemWidth: CGFloat = 0.0
    
    var tabViews: [TabView] {
        return contentView.subviews.flatMap({ $0 as? TabView })
    }
    
    var visibleFrame: CGRect {
        return convert(bounds, to: contentView)
    }
    
    func setup(pagingViewList: [ContentView], isSelection: Bool = false) {
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let sizeConstraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: contentView,
                               attribute: .height,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1.0,
                               constant: 45.0),
            NSLayoutConstraint(item: contentView,
                               attribute: .width,
                               relatedBy: .greaterThanOrEqual,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1.0,
                               constant: 0.0)
        ]
        NSLayoutConstraint.activate(sizeConstraints)
        addSubview(contentView)
        
        let attributes: [NSLayoutAttribute] = [.top, .bottom, .leading, .trailing]
        var marginConstraints: [NSLayoutConstraint] = []
        for attribute in attributes {
            marginConstraints.append(NSLayoutConstraint(item: contentView,
                                                        attribute: attribute,
                                                        relatedBy: .equal,
                                                        toItem: self,
                                                        attribute: attribute,
                                                        multiplier: 1.0,
                                                        constant: 0.0))
        }
        NSLayoutConstraint.activate(marginConstraints)
        
        
        var temporaryTotalTabViewWidth: CGFloat = 0.0
        for pagingView in pagingViewList {
            let title = pagingView.tabTitle ?? ""
            temporaryTotalTabViewWidth += TabView.calculateWidth(title: title)
        }
        
        let surplusWidth = UIScreen.main.bounds.width - temporaryTotalTabViewWidth
        let replenishSurplusWidth = surplusWidth > 0.0 ? surplusWidth / CGFloat(pagingViewList.count) : 0.0
        
        for _ in 1...3 {
            for pagingView in pagingViewList {
                let title = pagingView.tabTitle ?? ""
                
                let tabView = TabView.view()
                tabView.translatesAutoresizingMaskIntoConstraints = false
                tabView.backgroundColor = isSelection ? UIColor.red : UIColor.white
                tabView.setup(title: title, contentKey: pagingView.contentKey ?? "", replenishSurplusWidth: replenishSurplusWidth)
                tabView.titleLabel.textColor = isSelection ? .white : .black
                contentView.addSubview(tabView)
            }
        }
        contentView.layoutIfNeeded()
        
        setConstraintTabScrollView()
    }
    
    private func setConstraintTabScrollView() {
        var previousView: UIView?
        let tabHeight = bounds.height
        
        let lastIndex = contentView.subviews.count - 1
        for (index, view) in contentView.subviews.enumerated() {
            let viewConstraints: [NSLayoutConstraint] = [
                NSLayoutConstraint(item: view,
                                   attribute: .height,
                                   relatedBy: .equal,
                                   toItem: nil,
                                   attribute: .notAnAttribute,
                                   multiplier: 1.0,
                                   constant: tabHeight),
                NSLayoutConstraint(item: view,
                                   attribute: .width,
                                   relatedBy: .equal,
                                   toItem: nil,
                                   attribute: .notAnAttribute,
                                   multiplier: 1.0,
                                   constant: view.bounds.width)]
            NSLayoutConstraint.activate(viewConstraints)
            
            var constraints: [NSLayoutConstraint] = [
                NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0),
                NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            ]
            
            contentView.frame = CGRect(x: 0.0, y: 0.0, width: contentView.frame.width + view.bounds.width, height: tabHeight)
            if index == lastIndex {
                constraints.append(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
            }
            
            if let previousView = previousView {
                constraints.append(NSLayoutConstraint(item: view,
                                                      attribute: .leading,
                                                      relatedBy: .equal,
                                                      toItem: previousView,
                                                      attribute: .trailing,
                                                      multiplier: 1.0,
                                                      constant: 0.0))
            } else {
                constraints.append(NSLayoutConstraint(item: view,
                                                      attribute: .leading,
                                                      relatedBy: .equal,
                                                      toItem: contentView,
                                                      attribute: .leading,
                                                      multiplier: 1.0,
                                                      constant: 0.0))
            }
            
            NSLayoutConstraint.activate(constraints)
            previousView = view
        }
        
        layoutIfNeeded()
        
        if tabItemWidth == 0.0 {
            tabItemWidth = floor(contentSize.width / 3.0)
        }
        
        contentOffset.x = tabItemWidth
    }
}


