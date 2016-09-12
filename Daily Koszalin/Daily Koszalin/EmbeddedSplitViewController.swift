//
//  EmbeddedSplitViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 05.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class EmbeddedSplitViewController: UISplitViewController {
    
    var isCollapsing = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        let containerViewController = ContainerViewController()
        containerViewController.setEmbeddedViewController(self, delegate: appDelegate)
    }
    
    func unCollapseSecondaryVCOntoPrimary() {
        if isCollapsing == true {
            isCollapsing = false
        }
    }
    
}

// MARK: - UISplitViewControllerDelegate
extension EmbeddedSplitViewController: UISplitViewControllerDelegate {
    
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