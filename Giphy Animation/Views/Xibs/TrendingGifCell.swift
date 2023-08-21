//
//  TrendingGifCell.swift
//  Giphy Animation
//
//  Created by Admin on 20/08/23.
//

import UIKit

class TrendingGifCell: UICollectionViewCell {

    // MARK: - IBOutlets
    //=========================
    @IBOutlet weak var gifView: CustomImageView!
    @IBOutlet weak var favBtn: UIButton!
    
    // MARK: - Variables
    //=========================
    var favBtnClosure: ((Bool)->())?
    
    // MARK: - Lifecycle
    //========================
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        favBtn.layer.cornerRadius = 15
    }
    
    // MARK: - IBActions
    //========================
    @IBAction func favBtnTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        if let handler = favBtnClosure {
            handler(sender.isSelected)
        }
    }
    
    // MARK: - Functions
    //========================
    // Populate GIF Data with URL
    func populateData(with model: GiphyResponseModel) {
        self.gifView.loadGIF(from: model.images.original.gifURL)
        self.favBtn.isSelected = model.isSaved
    }
    
    // Populate GIF Data with UIImage
    func populateData(with model: GiphySavedModel) {
        self.gifView.image = model.image
        self.favBtn.isSelected = model.isSaved
    }

}
