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
    
    
    func setEmbeddedViewController(splitViewController: UISplitViewController?, delegate: AppDelegate?) {
        guard let splitVC = splitViewController else {
            return
        }
        viewController = splitVC
        
        addChildViewController(splitVC)
        view.addSubview(splitVC.view)
        splitVC.didMoveToParentViewController(self)
        
        delegate?.window?.rootViewController = self
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let willBeLandscape = size.width > size.height
        
        if let splitVC = viewController {
            if willBeLandscape {
                setOverrideTraitCollection(UITraitCollection(horizontalSizeClass: UIUserInterfaceSizeClass.Regular), forChildViewController: splitVC)
            } else {
                setOverrideTraitCollection(nil, forChildViewController: splitVC)
            }
        }
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    
}
