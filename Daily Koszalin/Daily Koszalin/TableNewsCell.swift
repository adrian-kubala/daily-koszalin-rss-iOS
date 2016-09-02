//
//  TableNewsCell.swift
//  Daily Koszalin
//
//  Created by Adrian on 01.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class TableNewsCell: UITableViewCell {
    
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDate: UILabel!
    @IBOutlet weak var cellFavIcon: UIImageView!

    func setSelectedBackgroundColor() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.6)
        selectedBackgroundView = backgroundView
    }
    
    func setTitle(title: String?) {
        cellTitle.text = title
    }
    
    func setPubDate(date: String?) {
        cellDate.text = date
    }
    
    func setFavIcon(source: String?) {
        if var searchUrl = source {
            searchUrl = "https://www.google.com/s2/favicons?domain=" + searchUrl
            if let data = NSData(contentsOfURL: NSURL(string: searchUrl)!) {
                let favIcon = UIImage(data: data)
                if let icon = favIcon {
                    cellFavIcon.image = icon
                }
            }
        }
    }
}