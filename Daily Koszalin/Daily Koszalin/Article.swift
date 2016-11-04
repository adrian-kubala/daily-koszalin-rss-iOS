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
  let pubDate: NSDate
  var favIcon: UIImage?
  
  var favIconDidLoad: (() -> ())?
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(source, forKey: "source")
    aCoder.encodeObject(title, forKey: "title")
    aCoder.encodeObject(link, forKey: "link")
    aCoder.encodeObject(pubDate, forKey: "pubDate")
    aCoder.encodeObject(favIcon, forKey: "favIcon")
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    let site = aDecoder.decodeObjectForKey("source") as? String
    let label = aDecoder.decodeObjectForKey("title") as? String
    let url = aDecoder.decodeObjectForKey("link") as? String
    let date = aDecoder.decodeObjectForKey("pubDate") as? NSDate
    let icon = aDecoder.decodeObjectForKey("favIcon") as? UIImage
    
    guard let source = site, title = label, link = url, pubDate = date, favIcon = icon else {
      return nil
    }
    
    self.init(source: source, title: title, link: link, pubDate: pubDate, favIcon: favIcon)
  }
  
  init(source: String, title: String, link: String, pubDate: NSDate, favIcon: UIImage? = nil) {
    self.source = source
    self.title = title
    self.link = link
    self.pubDate = pubDate
    self.favIcon = favIcon
    
    super.init()
  }
  
  func setupFavIcon(source: String) {
    DownloadManager.sharedInstance.downloadFavIcon(source) { [weak self] img in
      if let icon = img {
        self?.favIcon = icon
        self?.favIconDidLoad?()
      }
    }
  }
}