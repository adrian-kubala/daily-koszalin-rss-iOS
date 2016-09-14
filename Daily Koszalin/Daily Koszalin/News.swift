//
//  News.swift
//  Daily Koszalin
//
//  Created by Adrian on 27.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class News: NSObject, NSCoding {
    let source: String?
    let title: String?
    let link: String?
    let pubDate: NSDate?
    var favIcon: UIImage?
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
    static let ArchiveURL = DocumentsDirectory?.URLByAppendingPathComponent("news")
    
    func setupFavIcon(source: String) {
        DownloadManager.sharedInstance.downloadFavIcon(source) { [weak self] img in
            if let icon = img {
                self?.favIcon = icon
                DownloadManager.sharedInstance.cacheImage(icon, from: source)
            }
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(source, forKey: "source")
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(link, forKey: "link")
        aCoder.encodeObject(pubDate, forKey: "pubDate")
        aCoder.encodeObject(favIcon, forKey: "favIcon")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let site = aDecoder.decodeObjectForKey("source") as? String
        
        let label = aDecoder.decodeObjectForKey("title") as? String
        
        let url = aDecoder.decodeObjectForKey("link") as? String
        
        let date = aDecoder.decodeObjectForKey("pubDate") as? NSDate
        
        let icon = aDecoder.decodeObjectForKey("favIcon") as? UIImage
        
        self.init(source: site, title: label, link: url, pubDate: date, favIcon: icon)
    }
    
    init(source: String?, title: String?, link: String?, pubDate: NSDate?, favIcon: UIImage?) {
        self.source = source
        self.title = title
        self.link = link
        self.pubDate = pubDate
        self.favIcon = favIcon
        
        super.init()
    }
    
    static func getFilePath() -> String? {
        guard let path = News.ArchiveURL?.path else {
            return nil
        }
        
        return path
    }
}
