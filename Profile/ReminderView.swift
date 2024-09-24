//
//  ReminderView.swift
//  Avitan
//
//  Created by Владимир Кацап on 21.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class ReminderView: UIView , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    var collection: UICollectionView?
    var pageControl = UIPageControl()
    
    var frameScroll = CGFloat(0)
    
    var publisher: PassthroughSubject<Int, Never>?
    
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        createView()
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createView() {
        collection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .clear
            collection.delegate = self
            collection.dataSource = self
            collection.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            layout.scrollDirection = .horizontal
            collection.showsHorizontalScrollIndicator = false
            return collection
        }()
        addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(66)
        })
        
        pageControl.numberOfPages = remindersArr.count
        pageControl.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        pageControl.layer.cornerRadius = 12
        pageControl.isUserInteractionEnabled = false
        addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.width.equalTo(142)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func reloadComponents() {
        collection?.reloadData()
        pageControl.numberOfPages = remindersArr.count
        pageControl.currentPage = 0
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let centerPoint = CGPoint(x: scrollView.frame.size.width / 2 + scrollView.contentOffset.x, y: scrollView.frame.size.height / 2)
        if let indexPath = collection?.indexPathForItem(at: centerPoint) {
            // Центрирование текущей ячейки
            collection?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            pageControl.currentPage = indexPath.item
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Находим центр коллекции по X координате
        let centerPoint = CGPoint(x: scrollView.frame.size.width / 2 + scrollView.contentOffset.x, y: scrollView.frame.size.height / 2)
        
        // Находим индекс ближайшей ячейки
        if let indexPath = collection?.indexPathForItem(at: centerPoint) {
            // Обновляем текущую страницу pageControl
            pageControl.currentPage = indexPath.item
        }
    }


        
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            checkIfReachedEnd()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        checkIfReachedEnd()
    }
    
    private func checkIfReachedEnd() {
        if pageControl.currentPage == remindersArr.count - 1 {
            return
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return remindersArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 24
        cell.clipsToBounds = true
        
        let dateLabel = UILabel()
        dateLabel.text = remindersArr[indexPath.row].date
        dateLabel.textColor = .black
        dateLabel.font = .systemFont(ofSize: 13, weight: .regular)
        dateLabel.textAlignment = .right
        cell.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(15)
        }
        
        let nameLabel = UILabel()
        nameLabel.text = remindersArr[indexPath.row].title
        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .black
        nameLabel.textAlignment = .left
        cell.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(15)
            make.right.equalTo(dateLabel.snp.left).inset(-5)
        }
        
        
        let deskLabel = UILabel()
        deskLabel.text = remindersArr[indexPath.row].description
        deskLabel.textColor = .black
        deskLabel.font = .systemFont(ofSize: 15, weight: .regular)
        deskLabel.textAlignment = .left
        cell.addSubview(deskLabel)
        deskLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview().inset(15)
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: 66)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        publisher?.send(indexPath.row)
    }
    
    
}
