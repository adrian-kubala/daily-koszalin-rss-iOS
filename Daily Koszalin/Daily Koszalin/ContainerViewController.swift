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
            
            self.addChildViewController(viewController)
            self.view.addSubview(viewController.view)
            viewController.didMoveToParentViewController(self)
        }
    }
    
    static func collapseSecondaryVCOntoPrimary() {
        let splitViewDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        if splitViewDelegate.isCollapsed == false {
            splitViewDelegate.isCollapsed = true
        } else {
            splitViewDelegate.isCollapsed = false
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > size.height {
            self.setOverrideTraitCollection(UITraitCollection.init(horizontalSizeClass: UIUserInterfaceSizeClass.Regular), forChildViewController: viewController)
        } else {
            self.setOverrideTraitCollection(nil, forChildViewController: viewController)
        }
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
