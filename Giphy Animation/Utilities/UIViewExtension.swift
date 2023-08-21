//
//  UIViewExtension.swift
//  Giphy Animation
//
//  Created by Admin on 21/08/23.
//

import Foundation
import UIKit

extension UIView {
    
    func setBorder(width: CGFloat, color: UIColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
}
