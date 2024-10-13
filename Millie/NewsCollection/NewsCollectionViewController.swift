//
//  ViewController.swift
//  Millie
//
//  Created by 현은백 on 10/8/24.
//

import UIKit
import Combine

class NewsCollectionViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel = NewsArticleCollectionViewModel()
    private let newsCollectionView = OrientBasedCollectionView<NewsHeadLineCell, Article>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.bind(newsCollectionView)
        
        viewModel.$currentOrientation
            .receive(on: RunLoop.main)
            .sink { [weak self] orientation in
                self?.newsCollectionView.configureLayout(for: orientation)
            }
            .store(in: &cancellables)
        
        viewModel.$newsItems
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                self?.newsCollectionView.items = items
            }
            .store(in: &cancellables)
        
        viewModel.navigateToDetail
            .receive(on: RunLoop.main)
            .sink { [weak self] selectedItem in
                self?.pushToDetailWebsite(with: selectedItem)
            }
            .store(in: &cancellables)
        
        newsCollectionView.loadMorePublisher
            .sink { [weak self] in
                self?.viewModel.fetchNews()
            }
            .store(in: &cancellables)
    }
    
    private func pushToDetailWebsite(with item: Article) {
        let vc = NewsArticleWebViewController(article: item)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: Set up UI
private extension NewsCollectionViewController {
    func setUpUI() {
        view.backgroundColor = .white
        setNavigationTitle()
        
        newsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newsCollectionView)
        
        NSLayoutConstraint.activate([
            newsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newsCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            newsCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    private func setNavigationTitle() {
        self.title = "Articles"
        let attributes = [
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 24)!,
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        navigationController?.navigationBar.titleTextAttributes = attributes
    }
}
