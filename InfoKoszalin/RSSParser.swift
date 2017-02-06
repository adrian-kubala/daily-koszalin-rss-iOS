//
//  RSSParser.swift
//  Daily Koszalin
//
//  Created by Adrian Kubała on 07.12.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import Foundation
import FeedKit

class RSSParser {
  private var feedSources: [URL] = []
  private var articles: [Article] = []
  
  init(urls: [URL?]) {
    for url in urls {
      if let url = url {
        feedSources.append(url)
      }
    }
  }
  
  func parse() -> [Article] {
    for source in feedSources {
      FeedParser(URL: source)?.parse { [weak self] (result) in
        self?.specifyFeed(result)
      }
    }
    
    return articles
  }
  
  private func specifyFeed(_ result: Result) {
    switch result {
    case .rss(let rssFeed):
      handleRSSFeed(rssFeed)
    case .atom(let atomFeed):
      handleAtomFeed(atomFeed)
    case .failure(let error):
      print(error.localizedDescription)
    }
  }
  
  private func handleRSSFeed(_ feed: RSSFeed) {
    guard let items = feed.items else {
      return
    }
    
    for item in items {
      guard let feedLink = feed.link, let title = item.title, let link = item.link, let pubDate = item.pubDate else {
        continue
      }
      
      prepareArticleForRealm(source: feedLink, title: title, link: link, pubDate: pubDate)
    }
  }
  
  private func handleAtomFeed(_ feed: AtomFeed) {
    guard let items = feed.entries else {
      return
    }
    
    for item in items {
      let feedSource = feed.links?.first?.attributes?.href
      let itemSource = item.links?.first?.attributes?.href
      
      guard let feedLink = feedSource, let title = item.title, let link = itemSource, let pubDate = item.updated else {
        continue
      }
      
      prepareArticleForRealm(source: feedLink, title: title, link: link, pubDate: pubDate)
    }
  }
  
  private func prepareArticleForRealm(source: String, title: String, link: String, pubDate: Date) {
    let article = Article(value: ["source" : source,
                                  "title" : title,
                                  "link" : link,
                                  "pubDate" : pubDate])
    article.setupFavIcon(source)
    
    articles.append(article)
  }
}
