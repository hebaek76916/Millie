//
//  UIColor+Extension.swift
//  Millie
//
//  Created by 현은백 on 10/13/24.
//

import UIKit.UIColor

extension UIColor {

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
