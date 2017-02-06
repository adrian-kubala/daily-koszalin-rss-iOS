//
//  CustomWebView.swift
//  InfoKoszalin
//
//  Created by Adrian on 07.10.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class CustomWebView: UIWebView {
  func makeRequest(_ url: URL) {
    let request = URLRequest(url: url)
    loadRequest(request)
  }
  
  func setupAppearance() {
    guard isHidden == true else {
      return
    }
    
    isHidden = false
    scalesPageToFit = true
    contentMode = UIViewContentMode.scaleAspectFit
  }
}
