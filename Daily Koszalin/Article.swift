//
//  Article.swift
//  Daily Koszalin
//
//  Created by Adrian on 27.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class Article: NSObject, NSCoding {
  let source: String
  let title: String
  let link: String
  let pubDate: Date
  var favIcon: UIImage?
  
  var favIconDidLoad: (() -> ())?
  
  func encode(with aCoder: NSCoder) {
    aCoder.encode(source, forKey: "source")
    aCoder.encode(title, forKey: "title")
    aCoder.encode(link, forKey: "link")
    aCoder.encode(pubDate, forKey: "pubDate")
    aCoder.encode(favIcon, forKey: "favIcon")
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let site = aDecoder.decodeObject(forKey: "source") as? String
    let label = aDecoder.decodeObject(forKey: "title") as? String
    let url = aDecoder.decodeObject(forKey: "link") as? String
    let date = aDecoder.decodeObject(forKey: "pubDate") as? Date
    let icon = aDecoder.decodeObject(forKey: "favIcon") as? UIImage
    
    guard let source = site, let title = label, let link = url, let pubDate = date, let favIcon = icon else {
      return nil
    }
    
    self.init(source: source, title: title, link: link, pubDate: pubDate, favIcon: favIcon)
  }
  
  init(source: String, title: String, link: String, pubDate: Date, favIcon: UIImage? = nil) {
    self.source = source
    self.title = title
    self.link = link
    self.pubDate = pubDate
    self.favIcon = favIcon
    
    super.init()
  }
  
  func setupFavIcon(_ source: String) {
    DownloadManager.sharedInstance.downloadFavIcon(source) { [weak self] img in
      if let icon = img {
        self?.favIcon = icon
        self?.favIconDidLoad?()
      }
    }
  }
}
