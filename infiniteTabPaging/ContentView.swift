//
//  ContentView.swift
//  infiniteTabPaging
//
//  Created by HIROTOSHI KAWAUCHI on 2017/02/25.
//  Copyright © 2017年 HIROTOSHI KAWAUCHI. All rights reserved.
//

import UIKit

class ContentView: UIView {
    var tabTitle: String?
    var contentKey: String?
    @IBOutlet private weak var tabTitleLabel: UILabel!
    
    class func view() -> ContentView {
        let nib = UINib(nibName: "ContentView", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! ContentView
        return view
    }
    
    func setUp(title: String, contentKey: String) {
        tabTitle = title
        tabTitleLabel.text = title
        self.contentKey = contentKey
    }
}
