//
//  Article.swift
//  Daily Koszalin
//
//  Created by Adrian on 27.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import RealmSwift

class Article: Object {
  dynamic var source = ""
  dynamic var title = ""
  dynamic var link = ""
  dynamic var pubDate = Date()
  dynamic var favIcon: Data?
  
  dynamic var favIconDidLoad: (() -> ())?
  
  func setupFavIcon(_ source: String) {
    DownloadManager.sharedInstance.downloadFavIcon(source) { [weak self] icon in
      if let icon = icon {
        let realm = try! Realm()
        try! realm.write {
          self?.favIcon = icon
          self?.favIconDidLoad?()
        }
      }
    }
  }
  
  override class func primaryKey() -> String? {
    return "link"
  }
  
  override class func ignoredProperties() -> [String] {
    return ["favIconDidLoad"]
  }
}
