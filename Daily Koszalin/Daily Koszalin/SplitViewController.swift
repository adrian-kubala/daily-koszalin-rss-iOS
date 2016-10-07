//
//  SplitViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 05.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {
  var isCollapsing = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate = self
    preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
    
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
}

extension SplitViewController: UISplitViewControllerDelegate {
  func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
    return isCollapsing
  }
  
  func targetDisplayModeForActionInSplitViewController(svc: UISplitViewController) -> UISplitViewControllerDisplayMode {
    return UISplitViewControllerDisplayMode.PrimaryHidden
  }
  
  func splitViewController(svc: UISplitViewController, willChangeToDisplayMode displayMode: UISplitViewControllerDisplayMode) {
    NSNotificationCenter.defaultCenter().postNotificationName("DisplayModeChangeNotification", object: NSNumber.init(integer: displayMode.rawValue))
  }
}
