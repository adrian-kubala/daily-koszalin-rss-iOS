//
//  UITableView+scroll.swift
//  Daily Koszalin
//
//  Created by Adrian Kubała on 24.01.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

import UIKit

extension UITableView {
  func scrollBelowView(_ view: UIView) {
    var newBounds = bounds
    newBounds.origin.y = newBounds.origin.y + view.bounds.size.height
    bounds = newBounds
  }
}
