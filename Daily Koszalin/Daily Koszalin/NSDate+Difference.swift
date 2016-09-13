//
//  NSDate+Difference.swift
//  Daily Koszalin
//
//  Created by Adrian on 12.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import Foundation

extension NSDate {
    func daysBetweenDates(startDate: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Day], fromDate: startDate, toDate: self, options: [])
        
        return components.day
    }
}
