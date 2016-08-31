//
//  News.swift
//  Daily Koszalin
//
//  Created by Adrian on 27.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import Foundation

class News: NSObject, NSCoding {
    
    var title: String?
    var link: String?
    var pubDate: NSDate?
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("news")
    
    
    func setPubDateFormat(date: NSDate?) -> String? {
        
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "EEEE, d-MM-yyyy HH:mm"
        dayTimePeriodFormatter.locale = NSLocale(localeIdentifier: "pl_PL")
        
        let dateString = dayTimePeriodFormatter.stringFromDate(date!)
        
        return dateString
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.title, forKey: "title")
        aCoder.encodeObject(self.link, forKey: "link")
        aCoder.encodeObject(self.pubDate, forKey: "pubDate")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        let label = aDecoder.decodeObjectForKey("title") as? String
    
        let url = aDecoder.decodeObjectForKey("link") as? String
        
        let date = aDecoder.decodeObjectForKey("pubDate") as? NSDate
        
        self.init(title: label, link: url, pubDate: date)
    }

    init(title: String?, link: String?, pubDate: NSDate?) {
        self.title = title
        self.link = link
        self.pubDate = pubDate
        
        super.init()
    }
}