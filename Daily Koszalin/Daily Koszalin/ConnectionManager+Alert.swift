//
//  ConnectionManager+showConnectionAlert().swift
//  Daily Koszalin
//
//  Created by Adrian on 08.09.2016.
//  Copyright © 2016 Adrian Kubała. All rights reserved.
//
import UIKit

extension ConnectionManager {
    
    func showAlertIfNeeded(onViewController vc: UIViewController) {
        let alert = UIAlertController(title: "Błąd połączenia", message: "Upewnij się, że urządzenie jest podłączone do internetu i spróbuj ponownie.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        vc.presentViewController(alert, animated: true, completion: nil)
    }
    
    
}
