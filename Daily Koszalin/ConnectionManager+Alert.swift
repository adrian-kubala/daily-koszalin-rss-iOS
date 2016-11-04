//
//  ConnectionManager+showConnectionAlert().swift
//  Daily Koszalin
//
//  Created by Adrian on 08.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//
import UIKit

extension ConnectionManager {
  func showAlertIfNeeded(onViewController vc: UIViewController) -> Bool {
    guard !isConnectedToNetwork() else {
      return true
    }
    
    showConnectionAlert(onViewController: vc)
    return false
  }
  
  func showConnectionAlert(onViewController vc: UIViewController) {
    let alert = UIAlertController(title: "Błąd połączenia", message: "Upewnij się, że urządzenie jest podłączone do internetu i spróbuj ponownie.", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
    
    vc.present(alert, animated: true, completion: nil)
  }
}
