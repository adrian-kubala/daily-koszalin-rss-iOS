//
//  CustomToolbar.swift
//  InfoKoszalin
//
//  Created by Adrian on 07.10.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class CustomToolbar: UIToolbar {
  func removeFirstItem() {
    if items?.count == 2 {
      items?.remove(at: 0)
    }
  }
  
  func itemsCountIsLessThanTwo() -> Bool {
    if let items = items {
      return items.count < 2 ? true : false
    } else {
      return false
    }
  }
  
  func insertItem(_ item: UIBarButtonItem, at index: Int) {
    items?.insert(item, at: index)
  }
}
