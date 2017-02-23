//
//  SplitViewController.swift
//  InfoKoszalin
//
//  Created by Adrian on 05.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController, UISplitViewControllerDelegate {
  var isCollapsing = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate = self
    preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible
    
    setupRootViewController()
  }
  
  func setupRootViewController() {
    let containerViewController = ContainerViewController()
    containerViewController.embedViewController(self)
    containerViewController.setAsRootViewController()
  }
  
  func unCollapseSecondaryVCOntoPrimary() {
    if isCollapsing == true {
      isCollapsing = false
    }
  }
  
  // MARK: UISplitViewControllerDelegate
  
  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
    return isCollapsing
  }
  
  func targetDisplayModeForAction(in svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
    return UISplitViewControllerDisplayMode.primaryHidden
  }
  
  func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode) {
    NotificationCenter.default.post(name: Notification.Name.DisplayModeChangeNotification, object: NSNumber.init(value: displayMode.rawValue as Int))
  }
}
