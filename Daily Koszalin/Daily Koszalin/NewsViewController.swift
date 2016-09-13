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
    
    @IBOutlet var noNews: UILabel!
    var newsButtonitem : UIBarButtonItem?
    
    @IBOutlet var webViewIndicator: UIActivityIndicatorView!
    var newsURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webview.delegate = self
        webview.hidden = true
        toolbar.hidden = true
        
        newsButtonitem = UIBarButtonItem(title: "Wiadomości", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewsViewController.showNewsTableViewController))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewsViewController.splitViewControllerDisplayModeDidChange(_:)), name: "DisplayModeChangeNotification", object: nil)
    }
    
    func showNewsTableViewController() {
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
            }, completion: nil)
        insertDispModeBtn()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if newsURL != nil {
            noNews.hidden = true
            webViewIndicator.startAnimating()
        }
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
    
        override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
            let currentDisplayMode = splitViewController?.displayMode
            
            if previousTraitCollection?.verticalSizeClass == UIUserInterfaceSizeClass.Regular {
    
                if splitViewController?.displayMode == UISplitViewControllerDisplayMode.PrimaryHidden {
                    insertCustomDispModeBtn()
                } else {
                    insertDispModeBtn()
                }
            } else {
                if currentDisplayMode == UISplitViewControllerDisplayMode.AllVisible  {
                    insertDispModeBtn()
                }
            }

            super.traitCollectionDidChange(previousTraitCollection)
        }
    
    func removeFirstBarButton(bar: UIToolbar) {
        if bar.items?.count == 2 {
            bar.items?.removeAtIndex(0)
        }
    }
    
    func insertCustomDispModeBtn() {
        removeFirstBarButton(toolbar)
        
        if isToolbarCountLessThanTwo(), let barBtn = newsButtonitem {
            toolbar.items?.insert(barBtn, atIndex: 0)
        }
    }
    
    func insertDispModeBtn() {
        removeFirstBarButton(toolbar)
        
        if isToolbarCountLessThanTwo(), let splitVC = splitViewController {
            toolbar.items?.insert(splitVC.displayModeButtonItem(), atIndex: 0)
        }
    }
    
    func isToolbarCountLessThanTwo() -> Bool {
        if toolbar.items?.count < 2 {
            return true
        } else {
            return false
        }
    }
    
    
}

// MARK: - UIWebViewDelegate
extension NewsViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(webView: UIWebView) {
        webViewIndicator.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        
        if ConnectionManager.sharedInstance.isConnectedToNetwork() == false {
            ConnectionManager.sharedInstance.showAlertIfNeeded(onViewController: self)
        }
        
        webViewIndicator.stopAnimating()
    }
}
