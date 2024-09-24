//
//  SavingsCollectionViewCell.swift
//  Avitan
//
//  Created by Владимир Кацап on 25.09.2024.
//

import UIKit

class SavingsCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainSettings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    private lazy var opacityView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.12)
        view.layer.cornerRadius = 6
        return view
    }()
    
    private func mainSettings() {
        backgroundColor = .white
        layer.cornerRadius = 20
        addComponents()
    }
    
    private func addComponents() {
        addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(15)
        }
        
        addSubview(opacityView)
        opacityView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(15)
            make.height.equalTo(34)
        }
        
        opacityView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
    }
    
    func configure(summ: String, date: String) {
        countLabel.text = summ + " $"
        dateLabel.text = date
    }
    
    
    
}
