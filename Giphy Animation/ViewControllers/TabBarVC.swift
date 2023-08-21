//
//  TabBarVC.swift
//  Giphy Animation
//
//  Created by Admin on 19/08/23.
//

import Foundation
import UIKit

class TabBarVC: UITabBarController {
    
    // MARK: - VIEW LIFE CYCLE
    //========================
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }
    
}

// MARK: - PRIVATE FUNCTIONS
//==========================
extension TabBarVC {
    
    private func initialSetup() {
        self.delegate = self
        setupTabBar()
    }
    
    private func setupTabBar() {
        self.tabBar.backgroundColor = .white
        self.setViewControllers(getVCArray(), animated: true)
        for tabBarItemIndex in 0..<2 {
            switch tabBarItemIndex {
            case 0:
                setupTabItem(index: tabBarItemIndex, title: "", image: #imageLiteral(resourceName: "galleryUnSelected"), selectedImage:  #imageLiteral(resourceName: "gallerySelected"))
            case 1:
                setupTabItem(index: tabBarItemIndex, title: "", image: #imageLiteral(resourceName: "heartUnSelected"), selectedImage:  #imageLiteral(resourceName: "heartSelected"))
            default:
                return
            }
        }
    }
    
    private func createTabVC<T: UIViewController> (viewControlleType: T.Type) -> UIViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "\(viewControlleType.self)")
        let scene = UINavigationController(rootViewController: vc)
        scene.navigationBar.isHidden = true
        scene.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        return scene
    }
    
    private func getVCArray() -> [UIViewController] {
        let firstScene = createTabVC(viewControlleType: TrendingGifVC.self)
        let secondScene = createTabVC(viewControlleType: FavouritesGifVC.self)
        return [firstScene, secondScene]
    }
    
    private func setupTabItem(index: Int, title: String, image: UIImage?, selectedImage: UIImage?) {
        guard let tabs = self.tabBar.items, index < tabs.endIndex else { return }
        tabs[index].title = title
        tabs[index].image = image?.withRenderingMode(.alwaysOriginal)
        tabs[index].selectedImage = selectedImage?.withRenderingMode(.alwaysOriginal)
        tabs[index].setTitleTextAttributes([NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)], for: .normal)
        tabs[index].setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.darkGray], for: .selected)
    }
    
}

// MARK: - TRANSITION DELEGATES
//===========================
extension TabBarVC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let navController = viewController as? UINavigationController {
            navController.popToRootViewController(animated: true)
        }
    }
    
}
