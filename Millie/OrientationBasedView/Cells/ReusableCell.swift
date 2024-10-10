//
//  ReusableCell.swift
//  Millie
//
//  Created by 현은백 on 10/10/24.
//

import UIKit

protocol ReusableCell: UICollectionViewCell {
    static var identifier: String { get }
    func configure(with data: String)//TODO: Data 타입 변경해야함.
}

extension ReusableCell {
    static var identifier: String {
        return String(describing: self)
    }
}
