//
//  WebViewController.swift
//  Millie
//
//  Created by 현은백 on 10/11/24.
//

import UIKit
import WebKit
import Combine

class NewsArticleWebViewController: UIViewController, NetworkMonitorable {
    
    private let article: Article
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    internal let networkMonitor = NetworkMonitor.shared
    internal var cancellables = Set<AnyCancellable>()
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setupNetworkMonitoring()
        loadArticle()
    }
    
    internal func setupNetworkMonitoring() {
        networkMonitor.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                if !isConnected {
                    if let urlString = self?.article.url,
                        self?.isCacheAvailable(urlString: urlString) == true {
                        return
                    }
                    self?.alertNoInternet()
                }
            }
            .store(in: &cancellables)
    }
    
    private func alertNoInternet() {
        showAlert(
            title: "인터넷 연결",
            message: "인터넷 연결을 확인해주세요",
            actionTitle: "닫기",
            actionStyle: .destructive,
            isDestructive: true,
            completion: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
    }
    
    private func loadArticle() {
        if let url = URL(string: article.url) {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            showAlert(
            title: "오류",
                message: "유효하지 않은 URL입니다.",
                completion: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            )
        }
    }
    
    private func isCacheAvailable(urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        let request = URLRequest(url: url)
        if let _ = URLCache.shared.cachedResponse(for: request) {
            return true
        } else {
            return false
        }
    }
}

//MARK: WKNavigationDelegate
extension NewsArticleWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }


    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        showAlert(
        title: "오류",
            message: "서버 응답 오류",
            completion: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        )
    }
}

//MARK: Set up UI
extension NewsArticleWebViewController {
    
    func setUpUI() {
        setupNavigationBar()
        setupWebView()
        setUpIndicator()
        
        func setupWebView() {
            view.backgroundColor = MillieConstant.backgroundColor
            webView = WKWebView(frame: .zero)
            webView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(webView)
            NSLayoutConstraint.activate([
                webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
        
        func setUpIndicator() {
            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.color = .purple
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.hidesWhenStopped = true
            view.addSubview(activityIndicator)
            
            NSLayoutConstraint.activate([
                activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
    }
    
    private func setupNavigationBar() {
        self.title = article.title
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
}

