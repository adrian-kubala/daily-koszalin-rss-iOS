//
//  UITableView+animateCells.swift
//  InfoKoszalin
//
//  Created by Adrian Kubała on 25.01.2017.
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
}
