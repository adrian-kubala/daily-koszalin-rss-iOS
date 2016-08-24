//
//  NewsViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 19.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var pubDateBtnItem: UIBarButtonItem!
    
    var newsButtonitem : UIBarButtonItem!
    
    var newsURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webview.hidden = true
        toolbar.hidden = true
        
        newsButtonitem = UIBarButtonItem(title: "Wiadomości", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewsViewController.showNewsViewController))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewsViewController.handleFirstViewControllerDisplayModeChangeWithNotification(_:)), name: "PrimaryVCDisplayModeChangeNotification", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleFirstViewControllerDisplayModeChangeWithNotification(notification: NSNotification) {
        let displayModeObject = notification.object as? NSNumber
        let nextDisplayMode = displayModeObject?.integerValue
        
        if toolbar.items?.count == 3 {
            toolbar.items?.removeAtIndex(0)
        }
        
        if nextDisplayMode == UISplitViewControllerDisplayMode.PrimaryHidden.rawValue {
            toolbar.items?.insert(newsButtonitem, atIndex: 0)
        } else {
            toolbar.items?.insert(splitViewController!.displayModeButtonItem(), atIndex: 0)
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
            let firstItem = toolbar.items?[0]
            if firstItem?.title == "Wiadomości" {
                toolbar.items?.removeAtIndex(0)
            }
        } else if traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Regular {
            if toolbar.items?.count == 3 {
                toolbar.items?.removeAtIndex(0)
            }
            
            if splitViewController?.displayMode == UISplitViewControllerDisplayMode.PrimaryHidden {
                toolbar.items?.insert(newsButtonitem, atIndex: 0)
            } else {
                toolbar.items?.insert(self.splitViewController!.displayModeButtonItem(), atIndex: 0)
            }
        }
    }
    
    func showNewsViewController() {
        splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if newsURL != nil {
            let request = NSURLRequest(URL: newsURL!)
            webview.loadRequest(request)
            
            if webview.hidden == true {
                webview.hidden = false
                toolbar.hidden = false
            }
            
            if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
                toolbar.items?.insert(self.splitViewController!.displayModeButtonItem(), atIndex: 0)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPublishDate(sender: AnyObject) {
        
    }
}
