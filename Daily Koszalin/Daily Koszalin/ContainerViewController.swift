//
//  ContainerViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 19.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    var viewController: UISplitViewController!
    
    
    func setEmbeddedViewController(splitViewController: UISplitViewController!) {
        if let splitVC = splitViewController {
            viewController = splitVC
            
            addChildViewController(viewController)
            view.addSubview(viewController.view)
            viewController.didMoveToParentViewController(self)
        }
    }
    
    static func collapseSecondaryVCOntoPrimary() {
        let splitViewDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if splitViewDelegate.isCollapsed == true {
            splitViewDelegate.isCollapsed = false
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let willBeLandscape = size.width > size.height
        
        if willBeLandscape {
            setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular), forChildViewController: viewController)
        } else {
            setOverrideTraitCollection(nil, forChildViewController: viewController)
        }
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    
}
