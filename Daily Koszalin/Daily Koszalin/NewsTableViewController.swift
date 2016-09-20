//
//  NewsTableViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 19.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import FeedKit
import AlamofireImage

class NewsTableViewController: UITableViewController {
    static var arrayFilePath: String? {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
        return url?.URLByAppendingPathComponent("news").path
    }
    
    var news: [News] = []
    var filteredNews: [News] = []
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
            news = savedNews
        }
    }
    
    func loadNewsFromDisk() -> [News]? {
        guard let filePath = NewsTableViewController.arrayFilePath else {
            return nil
        }
        
        return NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [News]
    }
    
    func addNotificationObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewsTableViewController.saveNewsToDisk), name: "AppBecameInactive", object: nil)
    }
    
    func saveNewsToDisk() {
        guard let filePath = NewsTableViewController.arrayFilePath else {
            return
        }
        
        NSKeyedArchiver.archiveRootObject(news, toFile: filePath)
    }
    
    func setupRefreshControl() {
        refreshControl?.addTarget(self, action: #selector(NewsTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
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
            
            let obj = News(source: feedLink, title: title, link: link, pubDate: pubDate)
            obj.setupFavIcon(feedLink)
            self.news.append(obj)
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
            
            let obj = News(source: feedLink, title: title, link: link, pubDate: pubDate)
            obj.setupFavIcon(feedLink)
            self.news.append(obj)
        }
    }
    
    func isSuchArticle(title: String?) -> Bool {
        for article in news {
            guard article.title != title else {
                return true
            }
        }
        
        return false
    }
    
    private func sortAndReloadData() {
        news.sortInPlace({ $0.pubDate.compare($1.pubDate) == NSComparisonResult.OrderedDescending })
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ConnectionManager.sharedInstance.showAlertIfNeeded(onViewController: self)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIsActive() {
            return filteredNews.count
        }
        
        return news.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("newsCell")
        guard let newsCell = cell as? TableNewsCell else {
            return UITableViewCell()
        }
        
        let currentNews = chooseData(indexPath.row)
        newsCell.setupWithData(currentNews)
        
        return newsCell
    }
    
    func chooseData(row: Int) -> News {
        if searchIsActive() {
            return filteredNews[row]
        }
        return news[row]
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
        
        let newsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("idNewsViewController") as? NewsViewController
        
        guard let detailVC = newsVC else {
            return
        }
        
        detailVC.newsURL = NSURL(string: link)
        
        let mySplitVC = splitViewController as? EmbeddedSplitViewController
        mySplitVC?.unCollapseSecondaryVCOntoPrimary()
        
        showDetailViewController(detailVC, sender: self)
    }
    
    func filterContentForSearchText(searchText: String, scope: String) {
        filteredNews = news.filter { news in
            let currentDate = NSDate()
            let difference = currentDate.daysBetweenDates(news.pubDate)
            let dateMatch = doesMatchByDaysDifference(difference, within: scope)
            let filterMatch = (scope == Filters.all.rawValue) || dateMatch
            
            guard searchText.isEmpty == false else {
                return filterMatch
            }
            
            let lowerCaseTitle = news.title.lowercaseString
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
