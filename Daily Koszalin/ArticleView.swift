//
//  ArticleView.swift
//  Daily Koszalin
//
//  Created by Adrian on 01.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class ArticleView: UITableViewCell {
  @IBOutlet var titleView: UILabel!
  @IBOutlet var dateView: UILabel!
  @IBOutlet var favIconView: UIImageView!
  
  func setupWithData(_ news: Article) {
    setTitle(news.title)
    setPubDate(news.pubDate as Date)
    setupFavIcon(news)
    setSelectedBackgroundColor()
  }
  
  fileprivate func setTitle(_ title: String) {
    titleView.text = title
  }
  
  fileprivate func setPubDate(_ date: Date) {
    dateView.text = setPubDateFormat(date)
  }
  
  fileprivate func setPubDateFormat(_ date: Date) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, d-MM-yyyy HH:mm"
    dateFormatter.locale = Locale(identifier: "pl_PL")
    
    let dateString = dateFormatter.string(from: date)
    return dateString
  }
  
  fileprivate func setupFavIcon(_ news: Article) {
    if let favicon = news.favIcon {
      setFavIcon(favicon)
    } else {
//      news.favIconDidLoad = { [weak self] in
//        self?.setFavIcon(news.favIcon)
//      }
    }
  }
  
  fileprivate func setFavIcon(_ data: Data?) {
    let image = UIImage(data: data!)
    favIconView.image = image
  }
  
  fileprivate func setSelectedBackgroundColor() {
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor.blue.withAlphaComponent(0.6)
    selectedBackgroundView = backgroundView
  }
}
