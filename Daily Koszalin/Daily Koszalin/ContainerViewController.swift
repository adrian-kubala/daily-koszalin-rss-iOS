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
        if splitViewController != nil {
            viewController = splitViewController
            
            addChildViewController(viewController)
            view.addSubview(viewController.view)
            viewController.didMoveToParentViewController(self)
            
            self.setOverrideTraitCollection(UITraitCollection.init(horizontalSizeClass: UIUserInterfaceSizeClass.Regular), forChildViewController: viewController)
        }
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
