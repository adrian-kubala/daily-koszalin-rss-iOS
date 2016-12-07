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
  var parsedFeed: Feed?
  
  struct Feed {
    var source: String
    var title: String
    var link: String
    var pubDate: Date
  }
  
  func parse(_ url: URL) -> Feed? {
    FeedParser(URL: url)?.parse { [weak self] (result) in
      self?.specifyFeed(result)
    }
    
    return parsedFeed
  }
  
  func specifyFeed(_ result: Result) {
    switch result {
    case .rss(let rssFeed):
      handleRSSFeed(rssFeed)
    case .atom(let atomFeed):
      handleAtomFeed(atomFeed)
    case .failure(let error):
      print(error.localizedDescription)
    }
  }
  
  func handleRSSFeed(_ feed: RSSFeed) {
    guard let items = feed.items else {
      return
    }
    
    for item in items {
      guard let feedLink = feed.link, let title = item.title, let link = item.link, let pubDate = item.pubDate else {
        continue
      }
      
      parsedFeed = Feed(source: feedLink, title: title, link: link, pubDate: pubDate)
    }
  }
  
  func handleAtomFeed(_ feed: AtomFeed) {
    guard let items = feed.entries else {
      return
    }
    
    for item in items {
      let feedSource = feed.links?.first?.attributes?.href
      let itemSource = item.links?.first?.attributes?.href
      
      guard let feedLink = feedSource, let title = item.title, let link = itemSource, let pubDate = item.updated else {
        continue
      }
      
      parsedFeed = Feed(source: feedLink, title: title, link: link, pubDate: pubDate)
    }
  }
}
