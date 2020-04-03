//
//  UIAlertControllerDelegate.swift
//  Pixabay
//


import UIKit

@objc protocol UIAlertControllerDelegate {
    @objc optional
    func alertController(_ alertController: UIAlertController, clickedButtonAtIndex buttonIndex: Int)
}


func URLCacheAlertWithError(_ error: Error) -> UIAlertController {
    let message = "Error! \(error.localizedDescription) \((error as NSError).localizedFailureReason ?? "")"
    return URLCacheAlertWithMessage(message)
}


func URLCacheAlertWithMessage(_ message: String) -> UIAlertController {
    /* open an alert with an OK button */
        let alertController = UIAlertController(title: "URLCache",
            message: message,
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    return alertController
}

func URLCacheAlertWithMessageAndDelegate(_ title: String,_ message: String, _ alertControllerDelegate: UIAlertControllerDelegate) -> UIAlertController {
    /* open an alert with OK and Cancel buttons */
        let alertController = UIAlertController(title: title,
            message: message,
            preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) {action in
            alertControllerDelegate.alertController?(alertController, clickedButtonAtIndex: 0)
        })
        alertController.addAction(UIAlertAction(title: "OK", style: .default) {action in
            alertControllerDelegate.alertController?(alertController, clickedButtonAtIndex: 1)
        })
    return alertController
}

extension UIViewController {
    func presentAlert(error: Error) {
        let alertController = URLCacheAlertWithError(error)
        self.present(alertController, animated: true, completion: nil)
    }
    func presentAlert(message: String) {
        let alertController = URLCacheAlertWithMessage(message)
        self.present(alertController, animated: true, completion: nil)
    }
    func presentAlert(title: String, message: String, delegate: UIAlertControllerDelegate) {
        let alertController = URLCacheAlertWithMessageAndDelegate(title, message, delegate)
        self.present(alertController, animated: true, completion: nil)
    }
}

