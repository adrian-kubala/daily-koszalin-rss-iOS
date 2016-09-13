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
    @IBOutlet var webViewIndicator: UIActivityIndicatorView!
    
    var newsButtonitem : UIBarButtonItem?
    var newsURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webview.delegate = self

        setupNewsButtonItem()
        
        addNotificationObserver()
    }
    
    func setupNewsButtonItem() {
        newsButtonitem = UIBarButtonItem(title: "Wiadomości", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(NewsViewController.showNewsTableViewController))
    }
    
    func addNotificationObserver() {
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
            toolbar.hidden = false
            webViewIndicator.startAnimating()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let url = newsURL else {
            return
        }
        
        let request = NSURLRequest(URL: url)
        webview.loadRequest(request)
        
        setupWebView()
        
        if displayModeIsAllVisible() {
            insertDispModeBtn()
        } else {
            insertCustomDispModeBtn()
        }
    }
    
    func setupWebView() {
        if webview.hidden == true {
            webview.hidden = false
            webview.scalesPageToFit = true
            webview.contentMode = UIViewContentMode.ScaleAspectFit
        }
    }
    
    func displayModeIsAllVisible() -> Bool {
        let currentDisplayMode = splitViewController?.displayMode
        return currentDisplayMode == UISplitViewControllerDisplayMode.AllVisible
    }
    
    func splitViewControllerDisplayModeDidChange(notification: NSNotification) {
        let displayModeObject = notification.object as? NSNumber
        let nextDisplayMode = displayModeObject?.integerValue
        
        if nextDisplayMode == UISplitViewControllerDisplayMode.PrimaryHidden.rawValue {
            insertCustomDispModeBtn()
        } else {
            insertDispModeBtn()
        }
        
        guard traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.Pad else {
            return
        }
        
        if displayModeIsPrimaryHidden() {
            insertCustomDispModeBtn()
        }
    }
    
    func displayModeIsPrimaryHidden() -> Bool {
        let currentDisplayMode = splitViewController?.displayMode
        return currentDisplayMode == UISplitViewControllerDisplayMode.PrimaryHidden
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        if previousTraitCollection?.verticalSizeClass == UIUserInterfaceSizeClass.Regular {
            
            if displayModeIsPrimaryHidden() {
                insertCustomDispModeBtn()
            } else {
                insertDispModeBtn()
            }
        } else if displayModeIsAllVisible() {
            insertDispModeBtn()
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
