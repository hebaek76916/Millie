//
//  UIViewController+Extension.swift
//  Millie
//
//  Created by 현은백 on 10/10/24.
//

import UIKit

extension UIViewController {
    
    // Device의 orientation을 가져옴.
    static var currentInterfaceOrientation: UIInterfaceOrientation {
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
    
    func showAlert(
        title: String,
        message: String,
        actionTitle: String = "확인",
        actionStyle: UIAlertAction.Style = .default,
        isDestructive: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let actionStyle = isDestructive ? UIAlertAction.Style.destructive : actionStyle

        alert.addAction(UIAlertAction(title: actionTitle, style: actionStyle, handler: { [weak self] _ in
            completion?()
        }))

        self.present(alert, animated: true, completion: nil)
    }
}
