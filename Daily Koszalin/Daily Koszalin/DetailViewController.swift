//
//  DetailViewController.swift
//  Daily Koszalin
//
//  Created by Adrian on 19.08.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  @IBOutlet weak var webview: CustomWebView!
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
    newsButtonitem = UIBarButtonItem(title: "Wiadomości", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DetailViewController.showMasterViewController))
  }
  
  func addNotificationObserver() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailViewController.splitViewControllerDisplayModeDidChange(_:)), name: "DisplayModeChangeNotification", object: nil)
  }
  
  func showMasterViewController() {
    UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
      self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
      }, completion: nil)
    insertDispModeBtn()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    guard newsURL != nil else {
      return
    }
    
    noNews.hidden = true
    toolbar.hidden = false
    webViewIndicator.startAnimating()
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    guard let url = newsURL else {
      return
    }
    
    webview.makeRequest(url)
    webview.setupAppearance()
    
    insertDisplayModeButton()
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
  
  override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if previousTraitCollection?.verticalSizeClass == UIUserInterfaceSizeClass.Regular {
      insertDisplayModeButton()
    } else if displayModeIsAllVisible() {
      insertDispModeBtn()
    }
  }
  
  func displayModeIsPrimaryHidden() -> Bool {
    let currentDisplayMode = splitViewController?.displayMode
    return currentDisplayMode == UISplitViewControllerDisplayMode.PrimaryHidden
  }
  
  func insertDisplayModeButton() {
    if displayModeIsAllVisible() {
      insertDispModeBtn()
    } else {
      insertCustomDispModeBtn()
    }
  }
  
  func displayModeIsAllVisible() -> Bool {
    let currentDisplayMode = splitViewController?.displayMode
    return currentDisplayMode == UISplitViewControllerDisplayMode.AllVisible
  }
  
  func removeFirstBarButton(bar: UIToolbar) {
    if bar.items?.count == 2 {
      bar.items?.removeAtIndex(0)
    }
  }
  
  func insertDispModeBtn() {
    removeFirstBarButton(toolbar)
    
    if isToolbarCountLessThanTwo(), let splitVC = splitViewController {
      toolbar.items?.insert(splitVC.displayModeButtonItem(), atIndex: 0)
    }
  }
  
  func insertCustomDispModeBtn() {
    removeFirstBarButton(toolbar)
    
    if isToolbarCountLessThanTwo(), let barBtn = newsButtonitem {
      toolbar.items?.insert(barBtn, atIndex: 0)
    }
  }
  
  func isToolbarCountLessThanTwo() -> Bool {
    return toolbar.items?.count < 2 ? true : false
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}

extension DetailViewController: UIWebViewDelegate {
  func webViewDidFinishLoad(webView: UIWebView) {
    webViewIndicator.stopAnimating()
  }
  
  func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
    ConnectionManager.sharedInstance.showAlertIfNeeded(onViewController: self)
    
    webViewIndicator.stopAnimating()
  }
}
