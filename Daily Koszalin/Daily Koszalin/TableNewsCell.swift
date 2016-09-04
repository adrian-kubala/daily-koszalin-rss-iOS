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
    
    func setPubDate(date: String?) {
        cellDate.text = date
    }
    
    func setFavIcon(source: String?) {
        cellFavIcon.image = News.getFavIcon(source)
    }
}