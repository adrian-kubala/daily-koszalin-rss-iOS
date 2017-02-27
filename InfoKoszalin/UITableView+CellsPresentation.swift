//
//  UITableView+CellsPresentation.swift
//  InfoKoszalin
//
//  Created by Adrian Kubała on 23.02.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

import UIKit

extension UITableView {
  func reloadCellsWith(animationOptions: UIViewAnimationOptions) {
    UIView.transition(with: self,
                      duration: 0.35,
                      options: animationOptions,
                      animations: { () -> Void in
                        self.reloadData()
    }, completion: nil);
  }
  
  func enableSelfSizingCells(withEstimatedHeight height: CGFloat) {
    rowHeight = UITableViewAutomaticDimension
    estimatedRowHeight = height
  }
}
