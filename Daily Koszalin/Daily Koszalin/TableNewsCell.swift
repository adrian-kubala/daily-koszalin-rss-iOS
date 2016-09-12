//
//  TableNewsCell.swift
//  Daily Koszalin
//
//  Created by Adrian on 01.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class TableNewsCell: UITableViewCell {
    
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellFavIcon: UIImageView!

    func setSelectedBackgroundColor() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.6)
        selectedBackgroundView = backgroundView
    }
    
    func setTitle(title: String?) {
        cellTitle.text = title
    }
    
    func setPubDate(date: NSDate?) {
        cellDate.text = setPubDateFormat(date)
    }
    
    func setPubDateFormat(date: NSDate?) -> String? {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, d-MM-yyyy HH:mm"
        dateFormatter.locale = NSLocale(localeIdentifier: "pl_PL")
        
        guard let date = date else {
            return nil
        }
        
        let dateString = dateFormatter.stringFromDate(date)
        return dateString
    }
    
    func setFavIcon(icon: UIImage?) {
        cellFavIcon.image = icon
    }
}
