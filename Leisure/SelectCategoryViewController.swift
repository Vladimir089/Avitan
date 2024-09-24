//
//  SelectCategoryViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 23.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class SelectCategoryViewController: UIViewController {
    
    var categories: [Category]?
    var selectCategoryPablisher: PassthroughSubject<[Category], Never>?
    
    var cancellables = [AnyCancellable]()
    
    lazy var addButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        createInterface()
    }
    

    func createInterface() {
        let topLabel = UILabel()
        topLabel.text = "Category"
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 34, weight: .bold)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        }
        
        let backButton = UIButton(type: .system)
        backButton.setBackgroundImage(.backButton, for: .normal)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(topLabel)
            make.height.equalTo(44)
            make.width.equalTo(75)
        }
        backButton.tapPublisher
            .sink { _ in
                self.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
        
        let collection: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.showsVerticalScrollIndicator = false
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "3")
            layout.scrollDirection = .vertical
            collection.delegate = self
            collection.backgroundColor = .clear
            layout.minimumLineSpacing = 30
            collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 70, right: 0)
            collection.dataSource = self
            return collection
        }()
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-5)
        }
        
        addButton.setTitle("Add", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 28
        addButton.isEnabled = false
        addButton.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        addButton.alpha = 0.5
        view.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
        }
        addButton.tapPublisher
            .sink { _ in
                self.selectCategoryPablisher?.send(self.categories ?? [])
                self.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    func checkButton() {
        if categories?.count ?? 0 > 0 {
            addButton.backgroundColor = .red
            addButton.isEnabled = true
            addButton.alpha = 1
        } else {
            addButton.isEnabled = false
            addButton.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        }
    }
}

extension SelectCategoryViewController: UICollectionViewDelegate , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "3", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        cell.clipsToBounds = true
        
        let imageView = UIImageView(image: UIImage(data: categoryArr[indexPath.row].image))
        imageView.layer.cornerRadius = 46
        imageView.clipsToBounds = true
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(92)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        for i in categories ?? [] {
            if i.image == categoryArr[indexPath.row].image , i.name == categoryArr[indexPath.row].name {
                imageView.layer.borderWidth = 3
                imageView.layer.borderColor = UIColor.red.cgColor
            }
        }
        
        
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 11, weight: .regular)
        label.text = categoryArr[indexPath.row].name
        cell.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 92, height: 113)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let index = self.categories?.firstIndex(where: { $0.name == categoryArr[indexPath.row].name }) {
            categories?.remove(at: index)
            collectionView.reloadData()
        } else {
            categories?.append(categoryArr[indexPath.row])
            collectionView.reloadData()
        }
        checkButton()
    }
    
}
