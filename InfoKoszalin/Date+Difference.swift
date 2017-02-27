//
//  Date+Difference.swift
//  InfoKoszalin
//
//  Created by Adrian on 12.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import Foundation

extension Date {
  func daysBetween(date: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.day], from: date, to: self)
    
    return components.day!
  }
}
