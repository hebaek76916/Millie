//
//  ViewController.swift
//  Millie
//
//  Created by 현은백 on 10/8/24.
//

import UIKit

class ViewController: UIViewController {
    
    let items = Array(1...50).map { "\($0)" }
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceHorizontal = true
        return sv
    }()
    
    private let currentLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: currentLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        cv.register(NewsHeadLineCell.self, forCellWithReuseIdentifier: NewsHeadLineCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private var collectionViewWidthConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView()
        setupCollectionView()
        configureLayout(for: currentInterfaceOrientation.isPortrait ? .portrait : .landscapeLeft)
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupCollectionView() {
        scrollView.addSubview(collectionView)
        
        collectionViewWidthConstraint = collectionView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        collectionViewWidthConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            collectionView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    private func configureLayout(for orientation: UIInterfaceOrientation) {
        if orientation.isLandscape {
            setupLandscapeLayout()
        } else if orientation.isPortrait {
            setupPortraitLayout()
        }
    }
    
    private func setupPortraitLayout() {
        currentLayout.scrollDirection = .vertical
        currentLayout.itemSize = CGSize(width: 300, height: 120)
        currentLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        collectionViewWidthConstraint.isActive = false
        collectionViewWidthConstraint = collectionView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        collectionViewWidthConstraint.isActive = true
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func setupLandscapeLayout() {
        currentLayout.scrollDirection = .vertical
        currentLayout.itemSize = CGSize(width: 300, height: 120)
        currentLayout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        let numberOfColumns: CGFloat = 5
        let totalSpacing = (numberOfColumns - 1) * currentLayout.minimumInteritemSpacing
        let totalWidth = (300 * numberOfColumns) + totalSpacing
        
        collectionViewWidthConstraint.isActive = false
        collectionViewWidthConstraint = collectionView.widthAnchor.constraint(equalToConstant: totalWidth)
        collectionViewWidthConstraint.isActive = true
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            let newOrientation = self.currentInterfaceOrientation
            self.configureLayout(for: newOrientation)
        })
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: NewsHeadLineCell.identifier,
                for: indexPath) as? NewsHeadLineCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: items[indexPath.item])
        return cell
    }
}
