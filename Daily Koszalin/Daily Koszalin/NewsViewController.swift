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
        //let currentDisplayMode = self.splitViewController?.displayMode
        
        removeFirstBarButton(toolbar)
        
        if nextDisplayMode == UISplitViewControllerDisplayMode.PrimaryHidden.rawValue {
            insertCustomDispModeBtn()
        } else {
            insertDispModeBtn()
        }
    }
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if previousTraitCollection?.verticalSizeClass == UIUserInterfaceSizeClass.Compact{
            if var barItems = toolbar.items {
                if (barItems.first as UIBarButtonItem?) != nil {
                    barItems.removeAtIndex(0)
                }
   
            }
        } else if traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Regular {
            removeFirstBarButton(toolbar)
        
            if splitViewController?.displayMode == UISplitViewControllerDisplayMode.PrimaryHidden {
                insertCustomDispModeBtn()
            } else {
                insertDispModeBtn()
            }
        }
    }
    
    func insertDispModeBtn() {
        if let splitVC = self.splitViewController {
            toolbar.items?.insert(splitVC.displayModeButtonItem(), atIndex: 0)
        }
    }

    func insertCustomDispModeBtn() {
        toolbar.items?.insert(newsButtonitem, atIndex: 0)
    }
    
    func removeFirstBarButton(bar: UIToolbar) {
        if bar.items?.count == 3 {
            bar.items?.removeAtIndex(0)
        }
    }
    
    func showNewsTableViewController() {
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.AllVisible
            }, completion: nil)
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
            
            if self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
                insertDispModeBtn()
            }
        }
    }

    @IBAction func showPublishDate(sender: AnyObject) {
        let popoverViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("idPopoverViewController") as? PopoverViewController
       
        guard let popover = popoverViewController, let presentationController = popover.popoverPresentationController else {
            
            return
        }
        
        popover.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        presentationController.delegate = self
        
        self.presentViewController(popover, animated: true, completion: nil)
        
        presentationController.barButtonItem = pubDateBtnItem
        presentationController.permittedArrowDirections = .Any
        popover.preferredContentSize = CGSizeMake(200, 80)
        
        popover.lblMessage.text = publishDate
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    
}
