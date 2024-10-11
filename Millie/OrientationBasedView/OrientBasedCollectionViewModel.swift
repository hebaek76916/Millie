//
//  OrientBasedCollectionViewModel.swift
//  Millie
//
//  Created by 현은백 on 10/10/24.
//

import UIKit
import Combine

class OrientBasedCollectionViewModel {

    @Published var currentOrientation: UIInterfaceOrientation = .unknown
        
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupOrientationObserver()
    }
}

//MARK: Set Orientation
extension OrientBasedCollectionViewModel {
    
    private func setupOrientationObserver() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .map { [weak self] _ -> UIInterfaceOrientation in
                return self?.getCurrentInterfaceOrientation() ?? .unknown
            }
            .removeDuplicates()
            .sink { [weak self] newOrientation in
                self?.currentOrientation = newOrientation
            }
            .store(in: &cancellables)
    }
    
    private func getCurrentInterfaceOrientation() -> UIInterfaceOrientation {
        return UIViewController.currentInterfaceOrientation
    }
}
