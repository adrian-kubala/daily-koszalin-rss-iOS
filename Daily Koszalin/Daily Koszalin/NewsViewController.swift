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
    
    var newsButtonitem : UIBarButtonItem?
    
    var newsURL: NSURL?
    var publishDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webview.hidden = true
        toolbar.hidden = true
        
        newsButtonitem = UIBarButtonItem(title: "Wiadomości", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewsViewController.showNewsTableViewController))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewsViewController.splitViewControllerDisplayModeDidChange(_:)), name: "DisplayModeChangeNotification", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let url = newsURL {
            let request = NSURLRequest(URL: url)
            webview.loadRequest(request)
            
            if webview.hidden == true {
                webview.hidden = false
                webview.scalesPageToFit = true
                webview.contentMode = UIViewContentMode.ScaleAspectFit
                
                toolbar.hidden = false
            }

            let currentDisplayMode = splitViewController?.displayMode
            
            if currentDisplayMode == UISplitViewControllerDisplayMode.AllVisible {
                insertDispModeBtn()
            } else {
                insertCustomDispModeBtn()
            }
        }
    }
    
    func splitViewControllerDisplayModeDidChange(notification: NSNotification) {
        let displayModeObject = notification.object as? NSNumber
        let nextDisplayMode = displayModeObject?.integerValue
//        let currentDisplayMode = splitViewController?.displayMode
        
        if nextDisplayMode == UISplitViewControllerDisplayMode.PrimaryHidden.rawValue {
            insertCustomDispModeBtn()
        } else {
            insertDispModeBtn()
        }
        if traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            if splitViewController?.displayMode == UISplitViewControllerDisplayMode.PrimaryHidden {
                insertCustomDispModeBtn()
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
        override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
            if previousTraitCollection?.verticalSizeClass == UIUserInterfaceSizeClass.Regular {
    
                if splitViewController?.displayMode == UISplitViewControllerDisplayMode.PrimaryHidden {
                    insertCustomDispModeBtn()
                } else {
                    insertDispModeBtn()
                }
            }

            

    
            super.traitCollectionDidChange(previousTraitCollection)
        }
    
    func removeFirstBarButton(bar: UIToolbar) {
        if bar.items?.count == 3 {
            bar.items?.removeAtIndex(0)
        }
    }
    
    func insertDispModeBtn() {
        removeFirstBarButton(toolbar)
        
        if isToolbarCountLessThanThree(), let splitVC = splitViewController {
            toolbar.items?.insert(splitVC.displayModeButtonItem(), atIndex: 0)
        }
    }
    
    func insertCustomDispModeBtn() {
        removeFirstBarButton(toolbar)
        
        if isToolbarCountLessThanThree(), let barBtn = newsButtonitem {
            toolbar.items?.insert(barBtn, atIndex: 0)
        }
    }
    
    func isToolbarCountLessThanThree() -> Bool {
        if toolbar.items?.count < 3 {
            return true
        } else {
            return false
        }
    }
    
    func showNewsTableViewController() {
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
            }, completion: nil)
        insertDispModeBtn()
    }
    
    @IBAction func showPublishDate(sender: AnyObject) {
        let popoverViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("idPopoverViewController") as? PopoverViewController
        
        guard let popover = popoverViewController, let presentationController = popover.popoverPresentationController else {
            
            return
        }
        
        popover.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        presentationController.delegate = self
        
        presentViewController(popover, animated: true, completion: nil)
        
        presentationController.barButtonItem = pubDateBtnItem
        presentationController.permittedArrowDirections = .Any
        popover.preferredContentSize = CGSizeMake(200, 80)
        
        popover.lblMessage.text = publishDate
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
}
