//
//  NetworkMonitorable.swift
//  Millie
//
//  Created by 현은백 on 10/13/24.
//

import Foundation
import Combine

protocol NetworkMonitorable: AnyObject {
    var networkMonitor: NetworkMonitor { get }
    var cancellables: Set<AnyCancellable> { get set }

    func setupNetworkMonitoring()
    func networkStatusDidChange(isConnected: Bool)
}

extension NetworkMonitorable {
    var networkMonitor: NetworkMonitor {
        return NetworkMonitor.shared
    }

    func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.networkStatusDidChange(isConnected: isConnected)
            }
            .store(in: &cancellables)
    }

    func networkStatusDidChange(isConnected: Bool) {}
}
