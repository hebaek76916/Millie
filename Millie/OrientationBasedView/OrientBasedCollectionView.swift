//
//  File.swift
//  Millie
//
//  Created by 현은백 on 10/10/24.
//

import UIKit
import Combine

class OrientBasedCollectionView<CellType: ReusableCell, ModelType: Decodable>: UIView,
                                                                               UICollectionViewDataSource,
                                                                               UICollectionViewDelegateFlowLayout where CellType.DataType == ModelType {
    let didSelectItem = PassthroughSubject<ModelType, Never>()
    
    var items: [ModelType] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.alwaysBounceHorizontal = true
        return sv
    }()
    
    private var currentLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 300, height: 120)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: currentLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.register(CellType.self, forCellWithReuseIdentifier: CellType.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private var collectionViewWidthConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureLayout(for orientation: UIInterfaceOrientation) {
        if orientation.isLandscape {
            setupLandscapeLayout()
        } else if orientation.isPortrait {
            setupPortraitLayout()
        }
    }
    
    //MARK: For Customize Changing CollectionView Layout Method.
    public func configureCollectionViewLayout(layout: UICollectionViewFlowLayout) {
        collectionView.collectionViewLayout = layout
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.identifier, for: indexPath) as? CellType,
            let item = items[safe: indexPath.item]
        else {
            return UICollectionViewCell()
        }
        cell.configure(with: item)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedItem = items[safe: indexPath.item] else { return }
        didSelectItem.send(selectedItem)
    }
}

//MARK: Set up UI.
private extension OrientBasedCollectionView {
    
    func setUpUI() {
        setupScrollView()
        setupCollectionView()
    }
    
    func setupScrollView() {
        addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
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
}
