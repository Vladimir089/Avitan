//
//  ProfileViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 20.09.2024.
//

import UIKit
import Combine
import CombineCocoa
import StoreKit
import WebKit

var categoryArr: [Category] = []

class ProfileViewController: UIViewController {
    
    var user: User?
    var cancellables = [AnyCancellable]()
    
    var userPublisher = PassthroughSubject<User, Never>()
    var categoryPublisher = PassthroughSubject<Any, Never>()
    
    //ui
    lazy var profileImageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var ageTextField = UITextField()
    lazy var countryTextField = UITextField()
    var categoryCollection: UICollectionView?
    lazy var noCategoryView = UIView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        user = loadAthleteArrFromFile()
        checkUser()
        createInterface()
        checkCagegoryArr()
    }
    
    
    func checkUser() {
        userPublisher
            .sink { user in
                self.user = user
                self.profileImageView.image = UIImage(data: user.image)
                self.nameLabel.text = "Hi, \(user.name)"
                self.ageTextField.text = user.age
                self.countryTextField.text = user.countru
            }
            .store(in: &cancellables)
        
        if user == nil {
            let vc = ProfileEditViewController()
            vc.userNew = self.user
            vc.userPublisher = userPublisher
            self.navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    func checkCagegoryArr() {
        
        categoryPublisher
            .sink { category in
                self.checkCat()
                self.categoryCollection?.reloadData()
            }
            .store(in: &cancellables)
        
        checkCat()
    }
    
    func checkCat() {
        if categoryArr.count > 0 {
            noCategoryView.alpha = 0
            categoryCollection?.alpha = 1
        } else {
            noCategoryView.alpha = 1
            categoryCollection?.alpha = 0
        }
    }
    
    func loadAthleteArrFromFile() -> User? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("user.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode(User.self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }

    func createInterface() {
        profileImageView.image = UIImage(data: user?.image ?? Data())
        profileImageView.layer.cornerRadius = 22
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor.red.cgColor
        profileImageView.layer.borderWidth = 2
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.equalToSuperview().inset(15)
        }
        
        let editProfileButton: UIButton = {
            let button = UIButton(type: .system)
            button.setBackgroundImage(.editProfile, for: .normal)
           return button
        }()
        view.addSubview(editProfileButton)
        editProfileButton.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.right.equalToSuperview().inset(15)
            make.height.equalTo(22)
            make.width.equalTo(18)
        }
        editProfileButton.tapPublisher
            .sink { _ in
                let vc = ProfileEditViewController()
                vc.userNew = self.user
                vc.userPublisher = self.userPublisher
                vc.userNew = self.user
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
        
        nameLabel.text = "Hi, \(user?.name ?? "")"
        nameLabel.textColor = .white
        nameLabel.font = .systemFont(ofSize: 34, weight: .bold)
        nameLabel.textAlignment = .left
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.right.left.equalToSuperview().inset(15)
            make.top.equalTo(profileImageView.snp.bottom).inset(-10)
        }
        
        let agelabel = createLabel(text: "Age")
        view.addSubview(agelabel)
        agelabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(nameLabel.snp.bottom).inset(-15)
        }
        ageTextField = createTextField()
        ageTextField.text = user?.age ?? ""
        view.addSubview(ageTextField)
        ageTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(agelabel.snp.bottom).inset(-10)
        }
        
        let countryLabel = createLabel(text: "Country")
        view.addSubview(countryLabel)
        countryLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(ageTextField.snp.bottom).inset(-15)
            
        }
        
        countryTextField = createTextField()
        countryTextField.text = user?.countru ?? ""
        view.addSubview(countryTextField)
        countryTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(countryLabel.snp.bottom).inset(-10)
        }
        
        let categoryLabel = createLabel(text: "My category")
        view.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(countryTextField.snp.bottom).inset(-15)
        }
        
        let addCategoryButton = UIButton(type: .system)
        addCategoryButton.setBackgroundImage(.addCategoryButton, for: .normal)
        view.addSubview(addCategoryButton)
        addCategoryButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.height.width.equalTo(66)
            make.top.equalTo(categoryLabel.snp.bottom).inset(-10)
        }
        addCategoryButton.tapPublisher
            .sink { _ in
                let vc = AddAndEditCategoryViewController()
                vc.isNew = true
                vc.categoryPublisher = self.categoryPublisher
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
        
        noCategoryView = {
            let view = UIView()
            view.backgroundColor = .clear
            let topLabel = createLabel(text: "Empty")
            view.addSubview(topLabel)
            topLabel.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.bottom.equalTo(view.snp.centerY)
            }
            
            let botView = createLabel(text: "Create your first category")
            botView.font = .systemFont(ofSize: 17, weight: .bold)
            view.addSubview(botView)
            botView.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.top.equalTo(view.snp.centerY)
            }
            
            return view
        }()
        view.addSubview(noCategoryView)
        noCategoryView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(66)
            make.centerY.equalTo(addCategoryButton)
            make.right.equalTo(addCategoryButton.snp.left).inset(-10)
        }
        
        categoryCollection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .clear
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            collection.showsLargeContentViewer = false
            layout.scrollDirection = .vertical
            collection.delegate = self
            collection.dataSource = self
            layout.minimumInteritemSpacing = 5
            return collection
        }()
        view.addSubview(categoryCollection!)
        categoryCollection?.snp.makeConstraints({ make in
            make.left.equalToSuperview().inset(15)
            make.height.equalTo(66)
            make.centerY.equalTo(addCategoryButton)
            make.right.equalTo(addCategoryButton.snp.left).inset(-10)
        })
        
        let openCategoriesGesture = UITapGestureRecognizer(target: self, action: nil)
        categoryCollection?.addGestureRecognizer(openCategoriesGesture)
        openCategoriesGesture.tapPublisher
            .sink { _ in
                let vc = AllCategoriesViewController()
                vc.categoryPublisher = self.categoryPublisher
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
        
        let usageButton = createButton(title: "Usage Policy")
        view.addSubview(usageButton)
        usageButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(60)
            make.top.equalTo(categoryCollection!.snp.bottom).inset(-30)
        }
        usageButton.tapPublisher
            .sink { _ in
                self.policy()
            }
            .store(in: &cancellables)
        
        let rateButton = createButton(title: "Rate App")
        view.addSubview(rateButton)
        rateButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(60)
            make.top.equalTo(usageButton.snp.bottom).inset(-10)
        }
        rateButton.tapPublisher
            .sink { _ in
                self.rateApps()
            }
            .store(in: &cancellables)
        
        let shareButton = createButton(title: "Share App")
        view.addSubview(shareButton)
        shareButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(60)
            make.top.equalTo(rateButton.snp.bottom).inset(-10)
        }
        shareButton.tapPublisher
            .sink { _ in
                self.shareApps()
            }
            .store(in: &cancellables)
    }
    
    func rateApps() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            if let url = URL(string: "id") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    func shareApps() {
        let appURL = URL(string: "id")!
        let activityViewController = UIActivityViewController(activityItems: [appURL], applicationActivities: nil)
        
        // Настройка для показа в виде popover на iPad
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func policy() {
        let webVC = WebViewController()
        webVC.urlString = "pol"
        present(webVC, animated: true, completion: nil)
    }
    
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }
    
    func createTextField() -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 23
        textField.placeholder = "0"
        textField.isUserInteractionEnabled = false
        textField.textColor = .red
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightViewMode = .always
        textField.leftViewMode = .always
        textField.font = .systemFont(ofSize: 17, weight: .semibold)
        return textField
    }
 
    func createButton(title: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        button.layer.cornerRadius = 30
        let label = UILabel()
        label.text = title
        label.textColor = .white
        label.font = .systemFont(ofSize: 17, weight: .bold)
        button.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        
        let imageViewArrow = UIImageView(image: .systemButOpen)
        button.addSubview(imageViewArrow)
        imageViewArrow.snp.makeConstraints { make in
            make.height.width.equalTo(32)
            make.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        
        return button
    }
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if categoryArr.count > 3 {
            return categoryArr.prefix(3).count + 1
        } else {
            return categoryArr.prefix(3).count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 33
        cell.clipsToBounds = true
        
        if categoryArr.count >= 3 , indexPath.row != 3 {
            let imageView = UIImageView(image: UIImage(data: categoryArr[indexPath.row].image ))
            cell.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        } else if categoryArr.count >= 3 , indexPath.row == 3  {
            cell.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
            let label = UILabel()
            label.text = "+\(categoryArr.count - categoryArr.prefix(3).count)"
            label.textColor = .red
            label.font = .systemFont(ofSize: 22, weight: .bold)
            cell.addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        } else if categoryArr.count < 3 {
            let imageView = UIImageView(image: UIImage(data: categoryArr[indexPath.row].image ))
            cell.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 66, height: 66)
    }
    
    
}


struct User: Codable {
    var image:Data
    var name: String
    var age: String
    var countru: String
    
    init(image: Data, name: String, age: String, countru: String) {
        self.image = image
        self.name = name
        self.age = age
        self.countru = countru
    }
    
}

struct Category: Codable {
    var image: Data
    var name: String
    var description: String
    
    init(image: Data, name: String, description: String) {
        self.image = image
        self.name = name
        self.description = description
    }
}

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var urlString: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
        
        // Загружаем URL
        if let urlString = urlString, let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}
