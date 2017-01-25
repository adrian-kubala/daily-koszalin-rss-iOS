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
  var parser: RSSParser!
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
    
    setupRefreshControl()
    setupSearchController()
    setupTableView()
    setupParser()
  }
  
  private func setupTableView() {
    tableView.enableSelfSizingCells(withEstimatedHeight: 80)
    tableView.scrollBelowView(searchController.searchBar)
  }
  
  private func setupRefreshControl() {
    refreshControl?.addTarget(self, action: #selector(MasterViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
  }
  
  @objc private func handleRefresh(_ refreshControl: UIRefreshControl) {
    parseRSSContent {
      refreshControl.endRefreshing()
    }
  }
  
  private func setupSearchController() {
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    
    setupSearchBar()
  }
  
  private func setupSearchBar() {
    let searchBar = searchController.searchBar
    tableView.tableHeaderView = searchBar
    searchBar.autocapitalizationType = .none
    searchBar.placeholder = "Szukaj"
    searchBar.scopeButtonTitles = [Filters.all.rawValue, Filters.threeDays.rawValue, Filters.fiveDays.rawValue]
    searchBar.delegate = self
  }
  
  private enum Filters: String {
    case all = "Wszystkie"
    case threeDays = "Do 3 dni"
    case fiveDays = "Do 5 dni"
  }
  
  private func setupParser() {
    parser = RSSParser(urls: [URL(string: "http://www.gk24.pl/rss/gloskoszalinski.xml"),
                              URL(string: "http://koszalin.naszemiasto.pl/rss/artykuly/1.xml"),
                              URL(string: "http://www.koszalin.pl/pl/rss.xml")])
    parseRSSContent { }
  }
  
  private func parseRSSContent(completion: @escaping () -> Void) {
    DispatchQueue.global(qos: .background).async {
      var result: [Article] = []
      let isParsed: Bool
      
      if !ConnectionManager.sharedInstance.showAlertIfNeeded(onViewController: self) {
        isParsed = false
      } else {
        isParsed = true
        result = self.parser.parse()
      }
      
      DispatchQueue.main.async {
        if !isParsed {
          self.assignDataFromRealmIfNeeded()
        } else {
          self.updateRealm(with: result)
        }
        
        self.updateTableView()
        completion()
      }
    }
  }
  
  private func updateRealm(with objects: [Article]) {
    try! realm.write {
      realm.add(objects, update: true)
    }
    
    for object in objects {
      if !isSuchArticle(object) {
        articles.append(object)
      }
    }
  }
  
  private func isSuchArticle(_ article: Article) -> Bool {
    for existingArticle in articles {
      if article.link == existingArticle.link {
        return true
      }
    }
    return false
  }
  
  
  private func updateTableView() {
    articles.sort {
      $0.pubDate > $1.pubDate
    }
    
    if tableView.visibleCells.count == 0 {
      tableView.reloadCellsWith(animationOptions: .transitionCrossDissolve)
    }
  }
  
  private func assignDataFromRealmIfNeeded() {
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
  
  private func chooseData(_ row: Int) -> Article {
    return searchIsActive() ? filteredArticles[row] : articles[row]
  }
  
  private func searchIsActive() -> Bool {
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
  
  private func doesMatchByDaysDifference(_ days: Int, within scope: String) -> Bool {
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
