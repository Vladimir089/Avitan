//
//  AllCategoriesViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 21.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class AllCategoriesViewController: UIViewController {
    
    var categoryPublisher: PassthroughSubject<Any, Never>?
    
    var cancellables = [AnyCancellable]()
    
    var collection: UICollectionView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        createInterface()
        
        categoryPublisher?
            .sink(receiveValue: { _ in
                self.collection?.reloadData()
            })
            .store(in: &cancellables)
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
                self.navigationController?.popToRootViewController(animated: true)
            }
            .store(in: &cancellables)
        
        collection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            layout.scrollDirection = .vertical
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "2")
            collection.showsVerticalScrollIndicator = false
            collection.backgroundColor = .clear
            collection.delegate = self
            collection.dataSource = self
            layout.minimumLineSpacing = 30
            collection.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            return collection
        }()
        view.addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-10)
        })
    }

}


extension AllCategoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "2", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        
        cell.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        
        let imageView = UIImageView(image: UIImage(data: categoryArr[indexPath.row].image))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 46
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.width.height.equalTo(92)
        }
        
        let label = UILabel()
        label.text =  categoryArr[indexPath.row].name
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 11, weight: .regular)
        cell.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(5)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 92, height: 113)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = AddAndEditCategoryViewController()
        vc.index = indexPath.row
        vc.isNew = false
        vc.categoryPublisher = categoryPublisher
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
