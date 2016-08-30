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
        
        parseContentFromURL(rssURLs)
        
        self.refreshControl?.addTarget(self, action: #selector(NewsTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func parseContentFromURL(urls: [String: NSURL?]) {
        
        func sortAndReloadData() {
            news.sortInPlace({ $0.pubDate!.compare($1.pubDate!) == NSComparisonResult.OrderedDescending })
            self.tableView.reloadData()
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

                        self.news.append(News(title: item.title, link: item.link, pubDate: item.pubDate))
                    }
                case .Atom(let atomFeed):
                    dataLoop: for item in atomFeed.entries! {
                        
                        for article in self.news {
                            guard article.title != item.title else {
                                continue dataLoop
                            }
                        }
                        
                        self.news.append(News(title: item.title, link: String(item.links!.first!.attributes!.href!), pubDate: item.updated))
                    }
                case .Failure(let error):
                    print(error)
                }
            })
        }
        
        sortAndReloadData()
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

        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.6)
        cell.selectedBackgroundView = backgroundView
        
        let currentNews = news[indexPath.row]
        
        cell.textLabel?.text = currentNews.title
        cell.detailTextLabel?.text = currentNews.setPubDateFormat(currentNews.pubDate)

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
