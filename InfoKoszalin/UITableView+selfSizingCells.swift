//
//  UITableView+selfSizingCells.swift
//  InfoKoszalin
//
//  Created by Adrian Kubała on 24.01.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

import UIKit

extension UITableView {
  func enableSelfSizingCells(withEstimatedHeight height: CGFloat) {
    rowHeight = UITableViewAutomaticDimension
    estimatedRowHeight = height
  }
}
