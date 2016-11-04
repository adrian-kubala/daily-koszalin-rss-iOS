//
//  Article.swift
//  Daily Koszalin
//
//  Created by Adrian on 27.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import RealmSwift

class Article: Object {
  dynamic var source = ""
  dynamic var title = ""
  dynamic var link = ""
  dynamic var pubDate = Date()
  dynamic var favIcon: Data?
  
  var favIconDidLoad: (() -> ())?
  
  func setupFavIcon(_ source: String) {
    DownloadManager.sharedInstance.downloadFavIcon(source) { [weak self] img in
      if let icon = img {
        self?.favIcon = icon
        self?.favIconDidLoad?()
      }
    }
  }
}
