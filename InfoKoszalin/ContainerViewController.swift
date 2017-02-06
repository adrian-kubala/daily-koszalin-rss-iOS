//
//  ContainerViewController.swift
//  InfoKoszalin
//
//  Created by Adrian on 19.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
  var viewController: UISplitViewController?
  
  func embedViewController(_ vc: UISplitViewController?) {
    guard let splitVC = vc else {
      return
    }
    
    viewController = splitVC
    
    addChildViewController(splitVC)
    view.addSubview(splitVC.view)
    splitVC.didMove(toParentViewController: self)
  }
  
  func setAsRootViewController() {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    appDelegate?.window?.rootViewController = self
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    overrideTraitCollectionOnPhones(size)
  }
  
  func overrideTraitCollectionOnPhones(_ screenSize: CGSize) {
    guard isRunningOnPad() == false, let splitVC = viewController else {
      return
    }
    
    let willBeLandscape = screenSize.width > screenSize.height
    if willBeLandscape {
      setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.regular), forChildViewController: splitVC)
    } else {
      setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.compact), forChildViewController: splitVC)
    }
  }
  
  func isRunningOnPad() -> Bool {
    return traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.pad
  }
}
