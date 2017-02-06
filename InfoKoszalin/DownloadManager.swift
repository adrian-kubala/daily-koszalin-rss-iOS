//
//  DownloadManager.swift
//  Daily Koszalin
//
//  Created by Adrian on 14.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class DownloadManager {
  static let sharedInstance = DownloadManager()
  private init() {}
  
  func downloadFavIcon(from url: String?, completion: @escaping (Data?) -> ()) {
    guard var searchURL = url else {
      return
    }
    
    searchURL = "https://www.google.com/s2/favicons?domain=" + searchURL
    Alamofire.request(searchURL, method: .get, parameters: ["":""], encoding: URLEncoding.default, headers: nil).responseImage { response in
      let img = response.result.value
      let imgData = UIImagePNGRepresentation(img!)
      completion(imgData)
    }
  }
}
