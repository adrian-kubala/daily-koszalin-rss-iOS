//
//  ArticleView.swift
//  InfoKoszalin
//
//  Created by Adrian on 01.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class ArticleView: UITableViewCell {
  @IBOutlet var titleView: UILabel!
  @IBOutlet var dateView: UILabel!
  @IBOutlet var favIconView: UIImageView!
  
  func setupWithData(_ article: Article) {
    setTitle(article.title)
    setPubDate(article.pubDate as Date)
    setupFavIcon(article)
    setSelectedBackgroundColor()
  }
  
  private func setTitle(_ title: String) {
    titleView.text = title
  }
  
  private func setPubDate(_ date: Date) {
    dateView.text = setPubDateFormat(date)
  }
  
  private func setPubDateFormat(_ date: Date) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, d-MM-yyyy HH:mm"
    dateFormatter.locale = Locale(identifier: "pl_PL")
    
    let dateString = dateFormatter.string(from: date)
    return dateString
  }
  
  private func setupFavIcon(_ article: Article) {
    if let favicon = article.favIcon {
      setFavIcon(favicon)
    } else {
      article.favIconDidLoad = { [weak self] in
        self?.setFavIcon(article.favIcon)
      }
    }
  }
  
  private func setFavIcon(_ data: Data?) {
    let image = UIImage(data: data!)
    favIconView.image = image
  }
  
  private func setSelectedBackgroundColor() {
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor.blue.withAlphaComponent(0.6)
    selectedBackgroundView = backgroundView
  }
}
