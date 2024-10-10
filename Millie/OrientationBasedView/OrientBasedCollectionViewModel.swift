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
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .first as? UIWindowScene {
                return windowScene.interfaceOrientation
            }
        } else {
            return UIApplication.shared.statusBarOrientation
        }
        return .unknown
    }
    
    //TODO: API 호출.
}

