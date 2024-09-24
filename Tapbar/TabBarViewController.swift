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
    var savingsVC = UINavigationController(rootViewController: SavingsViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        UserDefaults.standard.setValue("1", forKey: "tab")
        categoryArr = loadCategoryArrFromFile() ?? []
        createInterface()
    }
    

    func createInterface() {
        let profileItem = UITabBarItem(title: "Profile", image: .profile.resize(targetSize: CGSize(width: 20, height: 20)), tag: 0)
        profileVC.tabBarItem = profileItem
        
        let leisureItem = UITabBarItem(title: "Leisure", image: .leisure.resize(targetSize: CGSize(width: 32, height: 32)), tag: 0)
        leisureVC.tabBarItem = leisureItem
        
        let saveItem = UITabBarItem(title: "Savings", image: .savings.resize(targetSize: CGSize(width: 32, height: 32)), tag: 0)
        savingsVC.tabBarItem = saveItem
        
        tabBar.unselectedItemTintColor = .white
        tabBar.tintColor = .red
        
        viewControllers = [profileVC, leisureVC, savingsVC]
    }
    
    func loadCategoryArrFromFile() -> [Category]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("category111.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([Category].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
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

