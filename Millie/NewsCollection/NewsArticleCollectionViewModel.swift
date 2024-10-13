//
//  NewsArticleCollectionViewModel.swift
//  Millie
//
//  Created by 현은백 on 10/11/24.
//

import UIKit
import Combine
import CoreData

//@MainActor
class NewsArticleCollectionViewModel: OrientBasedCollectionViewModel {
    @Published var newsItems: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    let navigateToDetail = PassthroughSubject<Article, Never>()
    private var cancellables = Set<AnyCancellable>()
    private let networkMonitor = NetworkMonitor.shared

    override init() {
        super.init()
        setupNetworkMonitoring()
    }
    
    public func bind(_ collectionView: OrientBasedCollectionView<NewsHeadLineCell, Article>) {
        collectionView.didSelectItem
            .sink { [weak self] selectedItem in
                self?.selectItem(selectedItem)
            }
            .store(in: &cancellables)
    }
    
    private func selectItem(_ item: Article) {
        guard
            let index = newsItems.firstIndex(where: { $0.id == item.id }),
            let _ = newsItems[safe: index]
        else { return }
        newsItems[index].setIsSelected(isSelected: true)
        navigateToDetail.send(newsItems[index])
    }
}

//MARK: Network Status
extension NewsArticleCollectionViewModel {
    
    private func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if isConnected {
                    Task {
                        await self.fetchNewsFromNetwork()
                    }
                } else {
                    self.fetchFromCoreData()
                }
            }
            .store(in: &cancellables)
    }
    
}

//MARK: Fetch Data
extension NewsArticleCollectionViewModel {
    
    func fetchNewsFromNetwork() async  {
        let result: Result<NewsEntry, NetworkError> = await withCheckedContinuation { continuation in
            HTTPClient.shared.request(endpoint: .topHeadlines(country: "us")) { result in
                continuation.resume(returning: result)
            }
        }
         
        switch result {
        case .success(let success):
            if let items = success.articles {
                self.newsItems = items
                await self.downloadImagesAndSaveToCoreData(articles: items)
            }
        case .failure(let failure):
            print(failure)
            self.fetchFromCoreData()
        }
    }
    
    private func fetchFromCoreData() {
        let sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        let fetchedEntities: [ArticleEntity] = CoreDataManager.shared.fetchAll(ArticleEntity.self, sortDescriptors: sortDescriptors)
        self.newsItems = fetchedEntities.map { entity in
            Article(
                source: nil,
                author: nil,
                title: entity.title,
                description: entity.descriptionText,
                url: entity.url ?? "",
                urlToImage: entity.urlToImage,
                publishedAt: entity.publishedAt,
                content: entity.content,
                isSelected: entity.isSelected
            )
        }
    }
    
    private func downloadImagesAndSaveToCoreData(articles: [Article]) async {
        await withTaskGroup(of: (Article, Data?).self) { group in
            for article in articles {
                if let imageURL = article.urlToImage {
                    group.addTask {
                        do {
                            let image = try await ImageLoader.shared.loadImage(from: imageURL)
                            let imageData = image?.jpegData(compressionQuality: 1.0)
                            return (article, imageData)
                        } catch {
                            print("\(imageURL) 이미지 다운로드 실패: \(error)")
                            return (article, nil)
                        }
                    }
                } else {
                    group.addTask { return (article, nil) }
                }
            }
            
            var articleEntities: [ArticleEntity] = []
            
            for await (article, imageData) in group {
                let articleEntity = ArticleEntity(context: CoreDataManager.shared.mainContext)
                articleEntity.title = article.title
                articleEntity.descriptionText = article.description
                articleEntity.url = article.url
                articleEntity.urlToImage = article.urlToImage
                articleEntity.publishedAt = article.publishedAt
                articleEntity.content = article.content
                articleEntity.imageData = imageData
                articleEntity.isSelected = article.isSelected
                articleEntities.append(articleEntity)
            }
            
            CoreDataManager.shared.save(articleEntities)
        }
    }

    private func clearAllCoreDataArticles() {
        CoreDataManager.shared.deleteAll(ArticleEntity.self)
    }
}
