//
//  NewsTableViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 19.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController, XMLParserDelegate {

    var xmlParser: XMLParser?
    
    
    func parsingWasFinished() {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = NSURL(string: "http://www.gk24.pl/rss/gloskoszalinski.xml")
        xmlParser = XMLParser()
        xmlParser?.delegate = self
        xmlParser?.parseURLContent(url!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return xmlParser?.arrParsedData.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("newsCell", forIndexPath: indexPath)

        let currentDictionary = (xmlParser?.arrParsedData[indexPath.row])! as Dictionary<String, String>
        
        cell.textLabel?.text = currentDictionary["title"]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dictionary = (xmlParser?.arrParsedData[indexPath.row])! as Dictionary<String, String>
        let newsLink = dictionary["link"]
        let pubDate = dictionary["pubDate"]
        
        let newsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("idNewsViewController") as! NewsViewController
 
        newsVC.newsURL = NSURL(string: newsLink!)
        newsVC.publishDate = pubDate
        
        showDetailViewController(newsVC, sender: self)
    }
    
    /*
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    */
    
    
}
