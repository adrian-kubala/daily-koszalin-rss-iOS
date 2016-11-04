//
//  CustomWebView.swift
//  Daily Koszalin
//
//  Created by Adrian on 07.10.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class CustomWebView: UIWebView {
  func makeRequest(url: NSURL) {
    let request = NSURLRequest(URL: url)
    loadRequest(request)
  }
  
  func setupAppearance() {
    guard hidden == true else {
      return
    }
    
    hidden = false
    scalesPageToFit = true
    contentMode = UIViewContentMode.ScaleAspectFit
  }
}
