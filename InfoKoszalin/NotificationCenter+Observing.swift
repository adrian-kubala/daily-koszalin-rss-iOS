//
//  NotificationCenter+observe.swift
//  CloudPlayer
//
//  Created by Adrian Kubała on 27.01.2017.
//  Copyright © 2017 Adrian Kubała. All rights reserved.
//

import Foundation

extension NotificationCenter {
  func observeNotification(withName name: Notification.Name?, block: @escaping (Notification) -> ()) {
    addObserver(forName: name, object: nil, queue: nil, using: block)
  }
}
