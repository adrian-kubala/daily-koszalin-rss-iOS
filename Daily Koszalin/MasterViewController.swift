//
//  MasterViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 19.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import FeedKit
import AlamofireImage

class MasterViewController: UITableViewController {
  static var dataFilePath: String? {
    let manager = FileManager.default
    let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
    return url?.appendingPathComponent("articles").path
  }
  
  let cellId = "articleView"
  var articles: [Article] = []
  var filteredArticles: [Article] = []
  let rssUrls = [URL(string: "http://www.gk24.pl/rss/gloskoszalinski.xml"),
                 URL(string: "http://www.radio.koszalin.pl/Content/rss/region.xml"),
                 URL(string: "http://koszalin.naszemiasto.pl/rss/artykuly/1.xml"),
                 URL(string: "http://www.koszalin.pl/pl/rss.xml")]
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    enableSelfSizingCells()
    assignLoadedNews()
    addNotificationObserver()
    setupRefreshControl()
    setupSearchController()
    parseRssContent()
  }
  
  func enableSelfSizingCells() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80
  }
  
  func assignLoadedNews() {
    if let savedNews = loadNewsFromDisk() {
      articles = savedNews
    }
  }
  
  func loadNewsFromDisk() -> [Article]? {
    guard let filePath = MasterViewController.dataFilePath else {
      return nil
    }
    
    return NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [Article]
  }
  
  func addNotificationObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.saveNewsToDisk), name: NSNotification.Name(rawValue: "AppBecameInactive"), object: nil)
  }
  
  func saveNewsToDisk() {
    guard let filePath = MasterViewController.dataFilePath else {
      return
    }
    
    NSKeyedArchiver.archiveRootObject(articles, toFile: filePath)
  }
  
  func setupRefreshControl() {
    refreshControl?.addTarget(self, action: #selector(MasterViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
  }
  
  func handleRefresh(_ refreshControl: UIRefreshControl) {
    if ConnectionManager.sharedInstance.showAlertIfNeeded(onViewController: self) {
      parseRssContent()
    }
    
    refreshControl.endRefreshing()
  }
  
  func setupSearchController() {
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    
    setupSearchBar()
  }
  
  func setupSearchBar() {
    let searchBar = searchController.searchBar
    tableView.tableHeaderView = searchBar
    searchBar.autocapitalizationType = .none
    searchBar.placeholder = "Wyszukaj"
    searchBar.scopeButtonTitles = [Filters.all.rawValue, Filters.threeDays.rawValue, Filters.fiveDays.rawValue]
    searchBar.delegate = self
  }
  
  enum Filters: String {
    case all = "Wszystkie"
    case threeDays = "Do 3 dni"
    case fiveDays = "Do 5 dni"
  }
  
  func parseRssContent() {
    for url in rssUrls {
      guard ConnectionManager.sharedInstance.isConnectedToNetwork() else {
        break
      }
      
      guard let feedUrl = url else {
        continue
      }
      
      FeedParser(URL: feedUrl)?.parse({ (result) in
        self.handleFeed(result)
      })
    }
    sortAndReloadData()
  }
  
  func handleFeed(_ result: Result) {
    switch result {
    case .rss(let rssFeed):
      handleRssFeed(rssFeed)
    case .atom(let atomFeed):
      handleAtomFeed(atomFeed)
    case .failure(let error):
      print(error.localizedDescription)
    }
  }
  
  func handleRssFeed(_ feed: RSSFeed) {
    guard let items = feed.items else {
      return
    }
    
    for item in items {
      guard isSuchArticle(item.title) == false else {
        continue
      }
      
      guard let feedLink = feed.link, let title = item.title, let link = item.link, let pubDate = item.pubDate else {
        continue
      }
      
      let article = Article(source: feedLink, title: title, link: link, pubDate: pubDate)
      article.setupFavIcon(feedLink)
      self.articles.append(article)
    }
  }
  
  func handleAtomFeed(_ feed: AtomFeed) {
    guard let items = feed.entries else {
      return
    }
    
    for item in items {
      guard isSuchArticle(item.title) == false else {
        continue
      }
      
      let feedSource = feed.links?.first?.attributes?.href
      let itemSource = item.links?.first?.attributes?.href
      
      guard let feedLink = feedSource, let title = item.title, let link = itemSource, let pubDate = item.updated else {
        continue
      }
      
      let article = Article(source: feedLink, title: title, link: link, pubDate: pubDate)
      article.setupFavIcon(feedLink)
      self.articles.append(article)
    }
  }
  
  func isSuchArticle(_ title: String?) -> Bool {
    for article in articles {
      guard article.title != title else {
        return true
      }
    }
    
    return false
  }
  
  fileprivate func sortAndReloadData() {
    articles.sort(by: {
      $0.pubDate.compare($1.pubDate as Date) == ComparisonResult.orderedDescending
    })
    tableView.reloadData()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    ConnectionManager.sharedInstance.showAlertIfNeeded(onViewController: self)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchIsActive() {
      return filteredArticles.count
    }
    
    return articles.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId)
    guard let articleView = cell as? ArticleView else {
      return UITableViewCell()
    }
    
    let currentNews = chooseData((indexPath as NSIndexPath).row)
    articleView.setupWithData(currentNews)
    
    return articleView
  }
  
  func chooseData(_ row: Int) -> Article {
    if searchIsActive() {
      return filteredArticles[row]
    }
    return articles[row]
  }
  
  func searchIsActive() -> Bool {
    return searchController.isActive ? true : false
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    let selectedCell = tableView.cellForRow(at: indexPath)
    let isAlreadySelected = selectedCell?.isSelected
    
    return isAlreadySelected == true ? nil : indexPath
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedNews = chooseData((indexPath as NSIndexPath).row)
    let link = selectedNews.link
    
    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "detailViewController")
    
    guard let detailViewController = viewController as? DetailViewController else {
      return
    }
    
    detailViewController.newsURL = URL(string: link)
    
    let splitVC = splitViewController as? SplitViewController
    splitVC?.unCollapseSecondaryVCOntoPrimary()
    
    showDetailViewController(detailViewController, sender: self)
  }
  
  func filterContentForSearchText(_ searchText: String, scope: String) {
    filteredArticles = articles.filter { article in
      let currentDate = Date()
      let difference = currentDate.daysBetweenDates(article.pubDate)
      let dateMatch = doesMatchByDaysDifference(difference, within: scope)
      let filterMatch = (scope == Filters.all.rawValue) || dateMatch
      
      guard searchText.isEmpty == false else {
        return filterMatch
      }
      
      let lowerCaseTitle = article.title.lowercased()
      let lowerCaseSearchText = searchText.lowercased()
      let isSuchTitle = lowerCaseTitle.contains(lowerCaseSearchText)
      return filterMatch && isSuchTitle
    }
    tableView.reloadData()
  }
  
  func doesMatchByDaysDifference(_ days: Int, within scope: String) -> Bool {
    var doesMatch = false
    switch scope {
    case Filters.threeDays.rawValue:
      if days < 3 {
        doesMatch = true
      }
    case Filters.fiveDays.rawValue:
      if days < 5 {
        doesMatch = true
      }
    default:
      doesMatch = false
    }
    return doesMatch
  }
}
