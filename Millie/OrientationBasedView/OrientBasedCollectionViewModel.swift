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
    
    @Published var newsItems: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    let navigateToDetail = PassthroughSubject<Article, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupOrientationObserver()
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
        //TODO: refactoring 해야함. UIViewCon
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
}
