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
    static var arrayFilePath: String? {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        return url?.URLByAppendingPathComponent("articles").path
    }
    
    typealias Data = Article
    var articles: [Data] = []
    var filteredArticles: [Article] = []
    let rssURLs = [NSURL(string: "http://www.gk24.pl/rss/gloskoszalinski.xml"),
                   NSURL(string: "http://www.radio.koszalin.pl/Content/rss/region.xml"),
                   NSURL(string: "http://koszalin.naszemiasto.pl/rss/artykuly/1.xml"),
                   NSURL(string: "http://www.koszalin.pl/pl/rss.xml")]
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableSelfSizingCells()

        assignLoadedNews()
        
        addNotificationObserver()
        
        setupRefreshControl()
        setupSearchController()
        
        parseRSSContent()
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
        guard let filePath = MasterViewController.arrayFilePath else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [Article]
    }
    
    func addNotificationObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MasterViewController.saveNewsToDisk), name: "AppBecameInactive", object: nil)
    }
    
    func saveNewsToDisk() {
        guard let filePath = MasterViewController.arrayFilePath else {
            return
        }
        
        NSKeyedArchiver.archiveRootObject(articles, toFile: filePath)
    }
    
    func setupRefreshControl() {
        refreshControl?.addTarget(self, action: #selector(MasterViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
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
        searchBar.autocapitalizationType = .None
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
    
    func handleFeed(result: Result) {
        switch result {
        case .RSS(let rssFeed):
            handleRssFeed(rssFeed)
        case .Atom(let atomFeed):
            handleAtomFeed(atomFeed)
        case .Failure(let error):
            print(error.localizedDescription)
        }
    }
    
    func handleRssFeed(feed: RSSFeed) {
        guard let items = feed.items else {
            return
        }
        
        for item in items {
            guard isSuchArticle(item.title) == false else {
                continue
            }
            
            guard let feedLink = feed.link, title = item.title, link = item.link, pubDate = item.pubDate else {
                continue
            }
            
            let obj = Article(source: feedLink, title: title, link: link, pubDate: pubDate)
            obj.setupFavIcon(feedLink)
            self.articles.append(obj)
        }
    }
    
    func handleAtomFeed(feed: AtomFeed) {
        guard let items = feed.entries else {
            return
        }
        
        for item in items {
            guard isSuchArticle(item.title) == false else {
                continue
            }
            
            let feedSource = feed.links?.first?.attributes?.href
            let itemSource = item.links?.first?.attributes?.href
            
            guard let feedLink = feedSource, title = item.title, link = itemSource, pubDate = item.updated else {
                continue
            }
            
            let obj = Article(source: feedLink, title: title, link: link, pubDate: pubDate)
            obj.setupFavIcon(feedLink)
            self.articles.append(obj)
        }
    }
    
    func isSuchArticle(title: String?) -> Bool {
        for article in articles {
            guard article.title != title else {
                return true
            }
        }
        
        return false
    }
    
    private func sortAndReloadData() {
        articles.sortInPlace({ $0.pubDate.compare($1.pubDate) == NSComparisonResult.OrderedDescending })
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ConnectionManager.sharedInstance.showAlertIfNeeded(onViewController: self)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIsActive() {
            return filteredArticles.count
        }
        
        return articles.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("articleView")
        guard let articleView = cell as? ArticleView else {
            return UITableViewCell()
        }
        
        let currentNews = chooseData(indexPath.row)
        articleView.setupWithData(currentNews)
        
        return articleView
    }
    
    func chooseData(row: Int) -> Article {
        if searchIsActive() {
            return filteredArticles[row]
        }
        return articles[row]
    }
    
    func searchIsActive() -> Bool {
        return searchController.active ? true : false
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        let isAlreadySelected = selectedCell?.selected
        
        return isAlreadySelected == true ? nil : indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedNews = chooseData(indexPath.row)
        let link = selectedNews.link
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("detailViewController") as? DetailViewController
        
        guard let detailViewController = viewController else {
            return
        }
        
        detailViewController.newsURL = NSURL(string: link)
        
        let mySplitVC = splitViewController as? EmbeddedSplitViewController
        mySplitVC?.unCollapseSecondaryVCOntoPrimary()
        
        showDetailViewController(detailViewController, sender: self)
    }
    
    func filterContentForSearchText(searchText: String, scope: String) {
        filteredArticles = articles.filter { article in
            let currentDate = NSDate()
            let difference = currentDate.daysBetweenDates(article.pubDate)
            let dateMatch = doesMatchByDaysDifference(difference, within: scope)
            let filterMatch = (scope == Filters.all.rawValue) || dateMatch
            
            guard searchText.isEmpty == false else {
                return filterMatch
            }
            
            let lowerCaseTitle = article.title.lowercaseString
            let lowerCaseSearchText = searchText.lowercaseString
            let isSuchTitle = lowerCaseTitle.containsString(lowerCaseSearchText)
            return filterMatch && isSuchTitle
        }
        tableView.reloadData()
    }
    
    func doesMatchByDaysDifference(days: Int, within scope: String) -> Bool {
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
