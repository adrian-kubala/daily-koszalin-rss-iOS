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
    static var favIcon: [String: UIImage?] = [:]
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first
    static let ArchiveURL = DocumentsDirectory?.URLByAppendingPathComponent("news")
    
    
    static func setFavIcon(source: String?) {
        guard let origin = source where isFavIcon(source) == false else {
            return
        }
        
        let img = downloadFavIcon(source)
        
        if let icon = img {
            favIcon[origin] = icon
        }
    }
    
    static func downloadFavIcon(url: String?) -> UIImage? {
        var img = UIImage?()
        if var searchUrl = url {
            searchUrl = "https://www.google.com/s2/favicons?domain=" + searchUrl
            
            if let iconUrl = NSURL(string: searchUrl) {
                if let data = NSData(contentsOfURL: iconUrl) {
                    img = UIImage(data: data)
                    return img
                }
            }
        }
        return nil
    }
    
    static func getFavIcon(source: String?) -> UIImage? {
        var img = UIImage?()
        
        if let origin = source {
            
            if let icon = favIcon[origin] {
                img = icon
            }
        }
        
        return img
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(source, forKey: "source")
        aCoder.encodeObject(title, forKey: "title")
        aCoder.encodeObject(link, forKey: "link")
        aCoder.encodeObject(pubDate, forKey: "pubDate")
        aCoder.encodeObject(News.getFavIcon(source), forKey: "favIcon")
    }
    
    static func isFavIcon(source: String?) -> Bool {
        let isNot = false
        if let origin = source {
            guard favIcon[origin] == nil else {
                return true
            }
        }
        return isNot
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
        if let origin = source {
            News.favIcon[origin] = favIcon
        }
        
        super.init()
    }
    
    static func getFilePath() -> String? {
        guard let path = News.ArchiveURL?.path else {
            return nil
        }
        
        return path
    }
}
