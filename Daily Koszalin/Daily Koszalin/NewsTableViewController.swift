//
//  NewsTableViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 19.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import FeedKit

class NewsTableViewController: UITableViewController {

    var news: [News] = []
    let rssURLs = ["gk24" : NSURL(string: "http://www.gk24.pl/rss/gloskoszalinski.xml"),
                   "radiokoszalin" : NSURL(string: "http://www.radio.koszalin.pl/Content/rss/region.xml"),
                   "naszemiasto" : NSURL(string: "http://koszalin.naszemiasto.pl/rss/artykuly/1.xml"),
                   "koszalin" : NSURL(string: "http://www.koszalin.pl/pl/rss.xml")]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl?.addTarget(self, action: #selector(NewsTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        if let savedNews = loadNewsFromDisk() {
            news = savedNews
        }
        
        parseContentFromURL(rssURLs)
    }
    
    func parseContentFromURL(urls: [String: NSURL?]) {
        
        func sortAndReloadData() {
            news.sortInPlace({ $0.pubDate?.compare($1.pubDate!) == NSComparisonResult.OrderedDescending })
            saveNewsToDisk()
            tableView.reloadData()
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 80
        }
        
        for url in urls.values {
            
            guard let feedUrl = url else {
                continue
            }
            
            FeedParser(URL: feedUrl)?.parse({ (result) in
                switch result {
                case .RSS(let rssFeed):
                    dataLoop: for item in rssFeed.items! {
                        
                        for article in self.news {
                            guard article.title != item.title else {
                                continue dataLoop
                            }
                        }
                        
                        News.setFavIcon(rssFeed.link)

                        self.news.append(News(source: rssFeed.link, title: item.title, link: item.link, pubDate: item.pubDate, favIcon: News.getFavIcon(rssFeed.link)))
                    }
                case .Atom(let atomFeed):
                    dataLoop: for item in atomFeed.entries! {
                        
                        for article in self.news {
                            guard article.title != item.title else {
                                continue dataLoop
                            }
                        }
                        
                        let feedSource = atomFeed.links?.first?.attributes?.href
                        let itemSource = item.links?.first?.attributes?.href
                        
                        News.setFavIcon(feedSource)
                        
                        self.news.append(News(source: feedSource, title: item.title, link: itemSource, pubDate: item.updated, favIcon: News.getFavIcon(feedSource)))
                    }
                case .Failure(let error):
                    print(error)
                }
            })
        }
        sortAndReloadData()
    }
    
    func saveNewsToDisk() {
        guard let filePath = News.getFilePath() else {
            return
        }
        NSKeyedArchiver.archiveRootObject(news, toFile: filePath)
    }
    
    func loadNewsFromDisk() -> [News]? {
        guard let filePath = News.getFilePath() else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? [News]
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        parseContentFromURL(rssURLs)
        
        refreshControl.endRefreshing()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath)

        let newsCell = cell as? TableNewsCell
        
        let currentNews = news[indexPath.row]
        
        newsCell?.setTitle(currentNews.title)
        newsCell?.setPubDate(currentNews.pubDate)
        newsCell?.setFavIcon(currentNews.source)
        newsCell?.setSelectedBackgroundColor()

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let link = news[indexPath.row].link
        let pubDate = news[indexPath.row].pubDate
        
        let newsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("idNewsViewController") as? NewsViewController
        
        if let url = link, let date = pubDate {
            newsVC?.newsURL = NSURL(string: url)
            newsVC?.publishDate = String(date)
        }
        
        guard let vc = newsVC else {
            return
        }
        
        ContainerViewController.collapseSecondaryVCOntoPrimary()
        
        showDetailViewController(vc, sender: self)
    }
    
    
}
