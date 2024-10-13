//
//  NewsArticleCollectionViewModel.swift
//  Millie
//
//  Created by 현은백 on 10/11/24.
//

import UIKit
import Combine
import CoreData

class NewsArticleCollectionViewModel: OrientBasedCollectionViewModel, NetworkMonitorable {
    
    @Published var newsItems: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    let navigateToDetail = PassthroughSubject<Article, Never>()
    internal var cancellables = Set<AnyCancellable>()
    internal let networkMonitor = NetworkMonitor.shared
    private var currentPage: Int = 1
    private var totalResults: Int = 0

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
            let item = newsItems[safe: index]
        else { return }
        newsItems[index].setIsSelected(isSelected: true)
        if !networkMonitor.isConnected {
            markArticleAsRead(articleID: item.id)
        }
        navigateToDetail.send(newsItems[index])
    }
    
    func markArticleAsRead(articleID: String) {
        let context = CoreDataManager.shared.mainContext
        let fetchRequest: NSFetchRequest<ArticleEntity> = ArticleEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", articleID)

        do {
            let results = try context.fetch(fetchRequest)
            if let articleEntity = results.first {
                articleEntity.isSelected = true
                try context.save()
            } else {
                print("해당 기사를 찾을 수 없습니다.")
            }
        } catch {
            print("기사 업데이트 오류: \(error)")
        }
    }

}

//MARK: Network Status
extension NewsArticleCollectionViewModel {
    
    internal func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self = self else { return }
                if isConnected {
                    Task {
                        await self.fetchNewsFromNetwork()
                    }
                } else {
                    guard self.newsItems.isEmpty else { return }
                    self.fetchFromCoreData()
                }
            }
            .store(in: &cancellables)
    }
    
}

//MARK: Fetch Data
extension NewsArticleCollectionViewModel {
    
    func fetchNews() {
        guard networkMonitor.isConnected else { return }
        guard !isLoading && (totalResults > newsItems.count) else { return }
        isLoading = true
        Task {
            await fetchNewsFromNetwork()
            isLoading = false
        }
    }
    
    func fetchNewsFromNetwork() async  {
        let result: Result<NewsEntry, NetworkError> = await withCheckedContinuation { continuation in
            HTTPClient.shared.request(endpoint: .topHeadlines(country: "us", page: currentPage)) { result in
                continuation.resume(returning: result)
            }
        }
         
        switch result {
        case .success(let success):
            totalResults = success.totalResults ?? 0
            if let items = success.articles {
                self.newsItems.append(contentsOf: items)
                self.currentPage += 1
                await self.downloadImagesAndSaveToCoreData(articles: items)
            }
        case .failure(let failure):
            print(failure)
            self.fetchFromCoreData()
        }
    }
    
    private func fetchFromCoreData() {
        let sortDescriptors = [NSSortDescriptor(key: "order", ascending: true)]
        let fetchedEntities: [ArticleEntity] = CoreDataManager.shared.fetchAll(ArticleEntity.self, sortDescriptors: sortDescriptors)
        self.newsItems = fetchedEntities.map { entity in
            Article(
                id: entity.id,
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
        clearAllCoreDataArticles()
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
            var order = 0
            for await (article, imageData) in group {
                let articleEntity = ArticleEntity(context: CoreDataManager.shared.mainContext)
                articleEntity.id = article.id
                articleEntity.title = article.title
                articleEntity.descriptionText = article.description
                articleEntity.url = article.url
                articleEntity.urlToImage = article.urlToImage
                articleEntity.publishedAt = article.publishedAt
                articleEntity.content = article.content
                articleEntity.imageData = imageData
                articleEntity.isSelected = article.isSelected
                articleEntity.order = "\(order)"
                order += 1
                articleEntities.append(articleEntity)
            }
            
            CoreDataManager.shared.save(articleEntities)
        }
    }

    private func clearAllCoreDataArticles() {
        CoreDataManager.shared.deleteAll(ArticleEntity.self)
    }
}
