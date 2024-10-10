//
//  ReusableCell.swift
//  Millie
//
//  Created by 현은백 on 10/10/24.
//

import UIKit

protocol ReusableCell: UICollectionViewCell {
    associatedtype DataType
    static var identifier: String { get }
    func configure(with data: DataType)
}

extension ReusableCell {
    static var identifier: String {
        return String(describing: self)
    }
}
