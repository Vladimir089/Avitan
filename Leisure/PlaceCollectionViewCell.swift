//
//  PlaceCollectionViewCell.swift
//  Avitan
//
//  Created by Владимир Кацап on 24.09.2024.
//

import UIKit

class PlaceCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageViewCategory = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 33
        clipsToBounds = true
        
        addSubview(imageViewCategory)
        createConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createConstraints() {
        imageViewCategory.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    func configure(image: UIImage) {
        imageViewCategory.image = image
        print(image)
    }
    
}
