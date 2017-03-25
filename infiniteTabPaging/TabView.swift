//
//  TabView.swift
//  infiniteTabPaging
//
//  Created by HIROTOSHI KAWAUCHI on 2017/02/24.
//  Copyright © 2017年 HIROTOSHI KAWAUCHI. All rights reserved.
//

import UIKit

class TabView: UIView {

    @IBOutlet weak var leadingMargin: NSLayoutConstraint!
    @IBOutlet weak var trailingMargin: NSLayoutConstraint!

    @IBOutlet weak var titleLabel: UILabel!
    var contentKey: String = ""
    class func view() -> TabView {
        return Bundle.main.loadNibNamed("TabView", owner: nil, options: nil)?.first as! TabView
    }
    
    class func calculateWidth(title: String) -> CGFloat {
        let attributes: [String: AnyObject] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14.0)]
        
        let rect = title.boundingRect(
            with: CGSize(width: .greatestFiniteMagnitude, height: 17.0),
            options: .usesLineFragmentOrigin,
            attributes: attributes,
            context: nil)
        return ceil(rect.width)
    }
    
    func setup(title: String, contentKey: String, replenishSurplusWidth: CGFloat = 0.0) {
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        self.contentKey = contentKey
        
        updateTabLayoutSize(replenishSurplusWidth: replenishSurplusWidth)
    }
    
    private func updateTabLayoutSize(replenishSurplusWidth: CGFloat = 0.0) {
        if replenishSurplusWidth > 0.0 {
            leadingMargin.constant += replenishSurplusWidth / 2
            trailingMargin.constant += replenishSurplusWidth / 2
        }
    }
}
