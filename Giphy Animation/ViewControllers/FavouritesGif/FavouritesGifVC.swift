//
//  FavouritesGifVC.swift
//  Giphy Animation
//
//  Created by Admin on 19/08/23.
//

import Foundation
import UIKit

class FavouritesGifVC: UIViewController {

    // MARK: - IBOutlets
    //=============================
    @IBOutlet weak var gridBtn: UIButton!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var favCollectionView: UICollectionView!
    @IBOutlet weak var stackContainerView: UIView!
    @IBOutlet weak var emptyDataLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    //===================================
    var viewModel = FavouritesGifViewModel()
    var removeWorkItem: DispatchWorkItem?

    enum ViewType {
        case grid
        case list
    }
    var viewTypeSelected: ViewType = .grid {
        didSet {
            switch viewTypeSelected {
            case .grid:
                self.gridBtn.backgroundColor = .darkGray
                self.listBtn.backgroundColor = .clear
                self.gridBtn.layer.cornerRadius = 10
                self.gridBtn.setTitleColor(.white, for: .normal)
                self.listBtn.setTitleColor(.black, for: .normal)
                self.configureCollectionViewLayout()
            case .list:
                self.listBtn.backgroundColor = .darkGray
                self.gridBtn.backgroundColor = .clear
                self.listBtn.layer.cornerRadius = 10
                self.listBtn.setTitleColor(.white, for: .normal)
                self.gridBtn.setTitleColor(.black, for: .normal)
                self.configureCollectionViewLayout()
            }
        }
    }
    
    // MARK: - Lifecycle
    //============================
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel.fetchGIFArray()
    }
    
    // MARK: - IBActions
    //===============================
    @IBAction func gridBtnTapped(_ sender: UIButton) {
        self.viewTypeSelected = .grid
        self.favCollectionView.scrollToItem(at: [0,0], at: .top, animated: false)
    }
    
    @IBAction func listBtnTapped(_ sender: UIButton) {
        self.viewTypeSelected = .list
        self.favCollectionView.scrollToItem(at: [0,0], at: .top, animated: false)
    }
    
}

// MARK: - Extension For Private Functions
//================================================
extension FavouritesGifVC {
    
    private func initialSetup() {
        self.emptyDataLabel.isHidden = true
        self.startLoader()
        self.viewModel.delegate = self
        self.stackContainerView.layer.cornerRadius = 10
        self.stackContainerView.setBorder(width: 1.0, color: .lightGray)
        self.viewTypeSelected = .grid
        self.setupCollectionView()
    }
    
    // TO Start the Loader
    func startLoader() {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    // TO Stop the Loader
    func stopLoader() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
    }
    
    // Setup Collection View
    private func setupCollectionView() {
        favCollectionView.register(UINib(nibName: "TrendingGifCell", bundle: nil), forCellWithReuseIdentifier: "TrendingGifCell")
        favCollectionView.register(UINib(nibName: "GridCell", bundle: nil), forCellWithReuseIdentifier: "GridCell")
        favCollectionView.delegate = self
        favCollectionView.dataSource = self
    }
    
    // Setup CollectionView Layout
    private func configureCollectionViewLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 350, height: 200)
        
        let compositonalLayout = createLayout()

        if self.viewTypeSelected == .grid {
            favCollectionView.collectionViewLayout = compositonalLayout
        } else {
            favCollectionView.collectionViewLayout = flowLayout
        }
        self.favCollectionView.reloadData()
    }
    
    // Create Compositional Layout
    func createLayout() -> UICollectionViewLayout {
        
        // 1st Group (i.e 3 gifs in a row)
        let tripletItem = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1.0)))

        tripletItem.contentInsets = NSDirectionalEdgeInsets(
          top: 5,
          leading: 5,
          bottom: 5,
          trailing: 5)

        let tripletGroup = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(4/9)),
          subitems: [tripletItem, tripletItem, tripletItem])
        
        // 2nd Group (One main item with a small item)
        let mainItem = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(2/3),
            heightDimension: .fractionalHeight(1.0)))

        mainItem.contentInsets = NSDirectionalEdgeInsets(
          top: 5,
          leading: 5,
          bottom: 5,
          trailing: 5)

        let singleItem = NSCollectionLayoutItem(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)))

        singleItem.contentInsets = NSDirectionalEdgeInsets(
          top: 5,
          leading: 5,
          bottom: 5,
          trailing: 5)

        let trailingGroup = NSCollectionLayoutGroup.vertical(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1/3),
            heightDimension: .fractionalHeight(1.0)),
          subitems: [singleItem])

        let mainWithPairGroup = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(4/9)),
          subitems: [mainItem, trailingGroup])
        
        // 3rdt Group (i.e 3 gifs in a row)
        // It's the same as the 1st one, so need to declare it again.
        
        // 4th Group [ Reversed of 2nd Group ] (Main with a small item)
        let mainWithPairReversedGroup = NSCollectionLayoutGroup.horizontal(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(4/9)),
          subitems: [trailingGroup, mainItem])
        
        
        // Nested Group containing all the subGroups
        let nestedGroup = NSCollectionLayoutGroup.vertical(
          layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(16/9)),
          subitems: [
            tripletGroup,
            mainWithPairGroup,
            tripletGroup,
            mainWithPairReversedGroup
          ])
        
        let section = NSCollectionLayoutSection(group: nestedGroup)
        section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        section.interGroupSpacing = 0

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // Handle Action For Fav Btn Tap action
    func handleFavBtnTap(isFav: Bool, index: Int) {
        self.removeWorkItem?.cancel()
        self.removeWorkItem = DispatchWorkItem { [weak self] in
            guard let `self` = self else { return }
            self.viewModel.removeGifFromCoreData(index: index)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: self.removeWorkItem!)
    }
    
}

// MARK: - Extension For Collection View Delegates
//================================================
extension FavouritesGifVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if viewTypeSelected == .grid {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as? GridCell else { return UICollectionViewCell() }
            cell.populateData(with: self.viewModel.getGIF(for: indexPath.row))
            cell.favBtnClosure = { [weak self] (isSelected) in
                guard let `self` = self else { return }
                self.handleFavBtnTap(isFav: isSelected, index: indexPath.item)
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingGifCell", for: indexPath) as? TrendingGifCell else { return UICollectionViewCell() }
            cell.populateData(with: self.viewModel.getGIF(for: indexPath.row))
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.gifsCount
    }
    
}

// MARK: - Extension For ViewModel Delegates
//================================================
extension FavouritesGifVC: FavGifVMDelegate {
    
    func fetchGifSuccess() {
        DispatchQueue.main.async {
            self.stopLoader()
            self.emptyDataLabel.isHidden = self.viewModel.gifsCount != 0
            self.favCollectionView.reloadData()
        }
    }
    
    func dataReload(index: Int) {
        DispatchQueue.main.async {
            self.favCollectionView.reloadData()
        }
    }
}
