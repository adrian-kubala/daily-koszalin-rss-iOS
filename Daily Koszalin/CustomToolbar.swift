//
//  CustomToolbar.swift
//  Daily Koszalin
//
//  Created by Adrian on 07.10.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class CustomToolbar: UIToolbar {
  func removeFirstItem() {
    if items?.count == 2 {
      items?.remove(at: 0)
    }
  }
  
  func itemsCountIsLessThanTwo() -> Bool {
    return items?.count < 2 ? true : false
  }
  
  func insertItem(_ item: UIBarButtonItem, at index: Int) {
    items?.insert(item, at: index)
  }
}
