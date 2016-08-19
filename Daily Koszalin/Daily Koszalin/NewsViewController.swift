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
    
    var newsURL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webview.hidden = true
        toolbar.hidden = true
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
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showPublishDate(sender: AnyObject) {
        
    }
}
