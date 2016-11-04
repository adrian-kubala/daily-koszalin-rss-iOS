//
//  NSDate+Difference.swift
//  Daily Koszalin
//
//  Created by Adrian on 12.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import Foundation

extension Date {
  func daysBetweenDates(_ startDate: Date) -> Int {
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components([.day], from: startDate, to: self, options: [])
    
    return components.day!
  }
}
