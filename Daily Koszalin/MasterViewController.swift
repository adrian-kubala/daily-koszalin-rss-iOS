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
import RealmSwift

class MasterViewController: UITableViewController {
  let rssURLs = [URL(string: "http://www.gk24.pl/rss/gloskoszalinski.xml"),
                 URL(string: "http://www.radio.koszalin.pl/Content/rss/region.xml"),
                 URL(string: "http://koszalin.naszemiasto.pl/rss/artykuly/1.xml"),
                 URL(string: "http://www.koszalin.pl/pl/rss.xml")]
  let searchController = UISearchController(searchResultsController: nil)
  
  let realm = try! Realm()
  var results: Results<Article> {
    let objects = realm.objects(Article.self)
    return objects.sorted(byProperty: "pubDate", ascending: false)
  }
  var articles: [Article] = []
  var filteredArticles: [Article] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    
    enableSelfSizingCells()
    setupRefreshControl()
    setupSearchController()
    parseRSSContent()
  }
  
  func enableSelfSizingCells() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 80
  }
  
  func setupRefreshControl() {
    refreshControl?.addTarget(self, action: #selector(MasterViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
  }
  
  func handleRefresh(_ refreshControl: UIRefreshControl) {
    if ConnectionManager.sharedInstance.showAlertIfNeeded(onViewController: self) {
      parseRSSContent()
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
  
  func parseRSSContent() {
    for url in rssURLs {
      guard ConnectionManager.sharedInstance.isConnectedToNetwork() else {
        assignDataFromRealmIfNeeded()
        break
      }
      
      guard let feedURL = url else {
        continue
      }
      
      FeedParser(URL: feedURL)?.parse { [weak self] (result) in
        self?.specifyFeed(result)
      }
    }
    updateTableView()
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
      
      prepareArticleForRealm(source: feedLink, title: title, link: link, pubDate: pubDate)
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
      
      prepareArticleForRealm(source: feedLink, title: title, link: link, pubDate: pubDate)
    }
  }
  
  func prepareArticleForRealm(source: String, title: String, link: String, pubDate: Date) {
    let article = Article(value: ["source" : source,
                                  "title" : title,
                                  "link" : link,
                                  "pubDate" : pubDate])
    article.setupFavIcon(source)
    updateRealm(with: article)
  }
  
  func updateRealm(with object: Object) {
    let article = object as! Article
    
    try! realm.write {
      realm.add(article, update: true)
    }
    
    if !isSuchArticle(article) {
      articles.append(article)
    }
  }
  
  func isSuchArticle(_ article: Article) -> Bool {
    for existingArticle in articles {
      if article.link == existingArticle.link {
        return true
      }
    }
    return false
  }
  
  
  func updateTableView() {
    articles.sort {
      $0.pubDate > $1.pubDate
    }
    tableView.reloadData()
  }
  
  func assignDataFromRealmIfNeeded() {
    articles = Array(results)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    _ = ConnectionManager.sharedInstance.showAlertIfNeeded(onViewController: self)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchIsActive() ? filteredArticles.count : articles.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "articleView")
    guard let articleView = cell as? ArticleView else {
      return UITableViewCell()
    }
    
    let currentNews = chooseData(indexPath.row)
    articleView.setupWithData(currentNews)
    
    return articleView
  }
  
  func chooseData(_ row: Int) -> Article {
    return searchIsActive() ? filteredArticles[row] : articles[row]
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
    guard ConnectionManager.sharedInstance.showAlertIfNeeded(onViewController: self) else {
      let selectedCell = tableView.cellForRow(at: indexPath)
      selectedCell?.setSelected(false, animated: true)
      
      return
    }
    
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
