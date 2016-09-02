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
        
        if let savedNews = loadNewsFromDisk() {
            news = savedNews
        }
        
        parseContentFromURL(rssURLs)
        
        refreshControl?.addTarget(self, action: #selector(NewsTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func parseContentFromURL(urls: [String: NSURL?]) {
        
        func sortAndReloadData() {
            news.sortInPlace({ $0.pubDate!.compare($1.pubDate!) == NSComparisonResult.OrderedDescending })
            saveNewsToDisk()
            tableView.reloadData()
        }
        
        for url in urls.values {
            FeedParser(URL: url!)?.parse({ (result) in
                switch result {
                case .RSS(let rssFeed):
                    dataLoop: for item in rssFeed.items! {
                        
                        for article in self.news {
                            guard article.title != item.title else {
                                continue dataLoop
                            }
                        }

                        self.news.append(News(source: rssFeed.link, title: item.title, link: item.link, pubDate: item.pubDate))
                    }
                case .Atom(let atomFeed):
                    dataLoop: for item in atomFeed.entries! {
                        
                        for article in self.news {
                            guard article.title != item.title else {
                                continue dataLoop
                            }
                        }
                        
                        self.news.append(News(source: atomFeed.links!.first!.attributes?.href, title: item.title, link: item.links!.first!.attributes!.href!, pubDate: item.updated))
                    }
                case .Failure(let error):
                    print(error)
                }
            })
        }
        sortAndReloadData()
    }
    
    func saveNewsToDisk() {
        NSKeyedArchiver.archiveRootObject(news, toFile: News.ArchiveURL.path!)
    }
    
    func loadNewsFromDisk() -> [News]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(News.ArchiveURL.path!) as? [News]
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
        
        newsCell?.setSelectedBackgroundColor()
        
        let currentNews = news[indexPath.row]
        
        newsCell?.setTitle(currentNews.title)
        newsCell?.setPubDate(currentNews.setPubDateFormat(currentNews.pubDate))
        newsCell?.setFavIcon(currentNews.source)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let link = news[indexPath.row].link
        let pubDate = news[indexPath.row].pubDate
        
        let newsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("idNewsViewController") as! NewsViewController
        
        newsVC.newsURL = NSURL(string: link!)
        newsVC.publishDate = String(pubDate!)
        
        ContainerViewController.collapseSecondaryVCOntoPrimary()
        
        showDetailViewController(newsVC, sender: self)
    }
    
    
}
