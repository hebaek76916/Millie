//
//  Array+Extension.swift
//  Millie
//
//  Created by 현은백 on 10/11/24.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
