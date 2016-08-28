//
//  NewsViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 19.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class NewsViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var webview: UIWebView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var pubDateBtnItem: UIBarButtonItem!
    
    var newsButtonitem : UIBarButtonItem!
    
    var newsURL: NSURL?
    var publishDate: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webview.hidden = true
        toolbar.hidden = true
        
        newsButtonitem = UIBarButtonItem(title: "Wiadomości", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewsViewController.showNewsTableViewController))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewsViewController.handleFirstViewControllerDisplayModeChangeWithNotification(_:)), name: "PrimaryVCDisplayModeChangeNotification", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func handleFirstViewControllerDisplayModeChangeWithNotification(notification: NSNotification) {
        let displayModeObject = notification.object as? NSNumber
        let nextDisplayMode = displayModeObject?.integerValue
        
        if toolbar.items?.count == 3 && splitViewController != nil {
            toolbar.items?.removeAtIndex(0)
        }
        
        if nextDisplayMode == UISplitViewControllerDisplayMode.PrimaryHidden.rawValue || self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Regular {
            toolbar.items?.insert(newsButtonitem, atIndex: 0)
        } else {
            if splitViewController != nil {
                toolbar.items?.insert(self.splitViewController!.displayModeButtonItem(), atIndex: 0)
            }
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
                if splitViewController != nil {
                    toolbar.items?.insert(self.splitViewController!.displayModeButtonItem(), atIndex: 0)
                }
            }
        }
    }
    
    func showNewsTableViewController() {
        splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
        
        if toolbar.items?.count == 3 {
            toolbar.items?.removeAtIndex(0)
            toolbar.items?.insert(self.splitViewController!.displayModeButtonItem(), atIndex: 0)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if newsURL != nil {
            let request = NSURLRequest(URL: newsURL!)
            webview.loadRequest(request)
            
            if webview.hidden == true {
                webview.hidden = false
                webview.scalesPageToFit = true
                webview.contentMode = UIViewContentMode.ScaleAspectFit
                
                toolbar.hidden = false
            }
            
            if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact && toolbar.items?.count < 3 {
                toolbar.items?.insert(self.splitViewController!.displayModeButtonItem(), atIndex: 0)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPublishDate(sender: AnyObject) {
        let popoverViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("idPopoverViewController") as? PopoverViewController
        
        popoverViewController?.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        popoverViewController?.popoverPresentationController?.delegate = self
        
        self.presentViewController(popoverViewController!, animated: true, completion: nil)
        
        popoverViewController?.popoverPresentationController?.barButtonItem = pubDateBtnItem
        popoverViewController?.popoverPresentationController?.permittedArrowDirections = .Any
        popoverViewController?.preferredContentSize = CGSizeMake(200, 80)
        
        popoverViewController?.lblMessage.text = publishDate
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
}
