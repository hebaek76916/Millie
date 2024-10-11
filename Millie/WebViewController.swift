//
//  WebViewController.swift
//  Millie
//
//  Created by 현은백 on 10/11/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    private let article: Article
    private var webView: WKWebView!
    
    init(article: Article) {
        self.article = article
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupWebView()
        loadArticle()
    }
    
    private func setupNavigationBar() {
        self.title = article.title
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    private func loadArticle() {
        if let url = URL(string: article.url) {
            let request = URLRequest(url: url)
            webView.load(request)
        } else {
            let alert = UIAlertController(title: "오류", message: "유효하지 않은 URL입니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: Set up UI
extension WebViewController {
    
    private func setupWebView() {
        view.backgroundColor = .white
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
}

