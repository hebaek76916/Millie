//
//  NewsArticleCollectionViewModel.swift
//  Millie
//
//  Created by 현은백 on 10/11/24.
//

import UIKit
import Combine

class NewsArticleCollectionViewModel: OrientBasedCollectionViewModel {

    @Published var newsItems: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    let navigateToDetail = PassthroughSubject<Article, Never>()
    
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        fetchNews()
    }
    
    public func bind(_ collectionView: OrientBasedCollectionView<NewsHeadLineCell, Article>) {
        collectionView.didSelectItem
            .sink { [weak self] selectedItem in
                self?.selectItem(selectedItem)
            }
            .store(in: &cancellables)
    }
    
    func fetchNews() {
        HTTPClient.shared.request(endpoint: .topHeadlines(country: "us")) { (result: Result<NewsEntry, NetworkError>) in
            switch result {
            case .success(let success):
                if let items = success.articles {
                    self.newsItems = items
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func selectItem(_ item: Article) {
        guard
            let index = newsItems.firstIndex(where: { $0.id == item.id }),
            let _ = newsItems[safe: index]
        else { return }
        newsItems[index].setIsSelected(isSelected: true)
        navigateToDetail.send(newsItems[index])
    }
}
