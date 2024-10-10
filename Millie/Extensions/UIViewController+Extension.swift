//
//  UIViewController+Extension.swift
//  Millie
//
//  Created by 현은백 on 10/10/24.
//

import UIKit

extension UIViewController {
    var currentInterfaceOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            if let orientation = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.windowScene?.interfaceOrientation,
               orientation == .portrait || orientation == .portraitUpsideDown
            {
                return .portrait
            } else {
                return .landscapeLeft
            }
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
}
