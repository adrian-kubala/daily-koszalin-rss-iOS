//
//  NotificationCenter+observe.swift
//  CloudPlayer
//
//  Created by Adrian Kubała on 27.01.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

import Foundation

extension NotificationCenter {
  func addObserver(forName name: Notification.Name?, using block: @escaping (Notification) -> ()) {
    addObserver(forName: name, object: nil, queue: nil, using: block)
  }
}
