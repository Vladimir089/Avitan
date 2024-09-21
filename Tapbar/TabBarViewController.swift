//
//  TabBarViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 20.09.2024.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var profileVC = UINavigationController(rootViewController: ProfileViewController())
    var leisureVC = UINavigationController(rootViewController: LeisureViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        UserDefaults.standard.setValue("1", forKey: "tab")
        createInterface()
    }
    

    func createInterface() {
        let profileItem = UITabBarItem(title: "Profile", image: .profile.resize(targetSize: CGSize(width: 20, height: 20)), tag: 0)
        profileVC.tabBarItem = profileItem
        
        let leisureItem = UITabBarItem(title: "Leisure", image: .leisure.resize(targetSize: CGSize(width: 32, height: 32)), tag: 0)
        leisureVC.tabBarItem = leisureItem
        
        tabBar.unselectedItemTintColor = .white
        tabBar.tintColor = .red
        
        viewControllers = [profileVC, leisureVC]
    }

}



extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIViewController {
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

