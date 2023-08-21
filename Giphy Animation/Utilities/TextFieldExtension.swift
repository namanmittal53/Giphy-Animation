//
//  TextFieldExtension.swift
//  Giphy Animation
//
//  Created by Admin on 20/08/23.
//

import Foundation
import UIKit

extension UITextField {
    
    func setupSearchTextField(placeholder: String) {
        self.placeholder = placeholder
        self.tintColor = .black
        let searchIconImageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIconImageView.tintColor = .gray

        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(searchIconImageView)
        searchIconImageView.center = iconContainerView.center

        self.leftView = iconContainerView
        self.leftViewMode = .always
        self.clearButtonMode = .whileEditing
    }
}

extension String {
    
    //Removes leading and trailing white spaces from the string
    var byRemovingLeadingTrailingWhiteSpacesAndNewLines:String {
        let spaceSet = CharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: spaceSet)
    }
}
