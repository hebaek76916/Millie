//
//  ViewController.swift
//  Millie
//
//  Created by 현은백 on 10/8/24.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel = OrientBasedCollectionViewModel()
    private let orientationAwareView = OrientBasedCollectionView<NewsHeadLineCell, Article>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.bind(orientationAwareView)
        
        viewModel.$currentOrientation
            .receive(on: RunLoop.main)
            .sink { [weak self] orientation in
                self?.orientationAwareView.configureLayout(for: self?.currentInterfaceOrientation ?? .portrait)
            }
            .store(in: &cancellables)
        
        viewModel.$newsItems
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.orientationAwareView.items = items
            }
            .store(in: &cancellables)
        
        viewModel.navigateToDetail
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedItem in
                self?.pushToDetailWebsite(with: selectedItem)
            }
            .store(in: &cancellables)
    }
    
    private func pushToDetailWebsite(with item: Article) {
        let vc = WebViewController(article: item)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: Set up UI
private extension ViewController {
    func setUpUI() {
        view.backgroundColor = .white
        orientationAwareView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(orientationAwareView)
        
        NSLayoutConstraint.activate([
            orientationAwareView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            orientationAwareView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            orientationAwareView.topAnchor.constraint(equalTo: view.topAnchor),
            orientationAwareView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
