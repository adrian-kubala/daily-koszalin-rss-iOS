//
//  ContainerViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 19.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    var viewController: UISplitViewController?
    
    func setEmbeddedViewController(splitViewController: UISplitViewController?) {
        guard let splitVC = splitViewController else {
            return
        }
        
        viewController = splitVC
        
        addChildViewController(splitVC)
        view.addSubview(splitVC.view)
        splitVC.didMoveToParentViewController(self)
    }
    
    func setAsRootViewController() {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate?.window?.rootViewController = self
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        overrideTraitCollectionOnPhones(size)
    }
    
    func overrideTraitCollectionOnPhones(screenSize: CGSize) {
        guard isRunningOnPad() == false, let splitVC = viewController else {
            return
        }
        
        let willBeLandscape = screenSize.width > screenSize.height
        
        if willBeLandscape {
            setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular), forChildViewController: splitVC)
        } else {
            setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Compact), forChildViewController: splitVC)
        }
    }
    
    func isRunningOnPad() -> Bool {
        return traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.Pad
    }
}
