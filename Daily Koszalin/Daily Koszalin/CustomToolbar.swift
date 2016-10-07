//
//  CustomToolbar.swift
//  Daily Koszalin
//
//  Created by Adrian on 07.10.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class CustomToolbar: UIToolbar {
  func removeFirstItem() {
    if items?.count == 2 {
      items?.removeAtIndex(0)
    }
  }
  
  func itemsCountIsLessThanTwo() -> Bool {
    return items?.count < 2 ? true : false
  }
  
  func insertItem(item: UIBarButtonItem, at index: Int) {
    items?.insert(item, atIndex: index)
  }
}
