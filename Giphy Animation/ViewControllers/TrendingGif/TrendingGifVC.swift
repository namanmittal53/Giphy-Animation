//
//  ViewController.swift
//  Giphy Animation
//
//  Created by Admin on 19/08/23.
//

import Foundation
import UIKit

class TrendingGifVC: UIViewController {
   
    // MARK: - IBOutlets
    //===============================
    @IBOutlet weak var gifListingCollectionView: UICollectionView!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    //===============================
    var viewModel = TrendingGifViewModel()
    var searchWorkItem: DispatchWorkItem?
    var saveAndRemoveWorkItem: DispatchWorkItem?

    // MARK: - Lifecycle
    //===============================
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initialSetup()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

    // MARK: - IBActions
    //===============================
    @IBAction func textfieldDidChangeEditing(_ sender: UITextField) {
        guard let text = sender.text?.byRemovingLeadingTrailingWhiteSpacesAndNewLines, !text.isEmpty else {
            self.viewModel.clearSearch()
            self.gifListingCollectionView.reloadData()
            return
        }
        searchWorkItem?.cancel()
        searchWorkItem = DispatchWorkItem { [weak self] in
            guard let `self` = self else { return }
            self.performSearch(with: text)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: searchWorkItem!)
    }
}

// MARK: - Extension For Private Functions
//================================================
extension TrendingGifVC {
    
    private func initialSetup() {
        self.startLoader()
        self.searchTextfield.delegate = self
        self.searchTextfield.setupSearchTextField(placeholder: "Search for GIF's")
        self.viewModel.delegate = self
        self.viewModel.fetchTrendingGifs()
        self.viewModel.fetchGIFURLs()
        self.setupCollectionView()
    }
    
    // Setup Collection View
    private func setupCollectionView() {
        self.gifListingCollectionView.delegate  = self
        self.gifListingCollectionView.dataSource = self
        self.gifListingCollectionView.register(UINib(nibName: "TrendingGifCell", bundle: nil), forCellWithReuseIdentifier: "TrendingGifCell")
    }
    
    // Search any GIF
    func performSearch(with query: String) {
        self.viewModel.searchText(searchTextStr: query)
    }
    
    // Handle Action For Fav Btn Tap action
    func handleFavBtnTap(isFav: Bool, index: Int) {
        self.saveAndRemoveWorkItem?.cancel()
        self.saveAndRemoveWorkItem = DispatchWorkItem { [weak self] in
            guard let `self` = self else { return }
            if isFav {
                self.viewModel.saveGifToCoreData(index: index)
            } else {
                self.viewModel.removeGifFromCoreData(index: index)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: self.saveAndRemoveWorkItem!)
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
}

// MARK: - Extension For View Model Delegate Functions
//================================================
extension TrendingGifVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.totalGifCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingGifCell", for: indexPath) as? TrendingGifCell else { return UICollectionViewCell() }
        cell.populateData(with: self.viewModel.getGifModelForIndex(index: indexPath.item))
        cell.favBtnClosure = { [weak self] (isSelected) in
            guard let `self` = self else { return }
            self.handleFavBtnTap(isFav: isSelected, index: indexPath.item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.viewModel.getGifSizeForIndex(index: indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TrendingGifCell {
            cell.populateData(with: self.viewModel.getGifModelForIndex(index: indexPath.item))
        }
    }
    
}

// MARK: - Extension For View Model Delegate Functions
//================================================
extension TrendingGifVC: TrendingGifVMDelegate {
    
    func dataReload(index: Int) {
        DispatchQueue.main.async {
            self.gifListingCollectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    func apiSuccess() {
        DispatchQueue.main.async {
            self.stopLoader()
            self.gifListingCollectionView.reloadData()
            self.gifListingCollectionView.scrollToItem(at: [0,0], at: .top, animated: true)
        }
    }
    
    func apiFailure(errMsg: String) {
        print(errMsg)
    }
    
}

// MARK: - Extension For TextField Delegate Functions
//================================================
extension TrendingGifVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

