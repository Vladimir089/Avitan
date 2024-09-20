//
//  OnbUserViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 20.09.2024.
//

import UIKit
import CombineCocoa
import Combine

class OnbUserViewController: UIViewController {
    
    lazy var topLabel = UILabel()
    lazy var imageView = UIImageView()
    var cancellable: AnyCancellable?
    
    var tap = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        createInterface()
        view.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
    }
    

    func createInterface() {
        topLabel.text = "Plan your vacation wisely"
        topLabel.textColor = .black
        topLabel.font = .systemFont(ofSize: 44, weight: .bold)
        topLabel.numberOfLines = 2
        topLabel.textAlignment = .center
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
            make.left.right.equalToSuperview().inset(15)
        }
        
        imageView.image = .us1
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(527)
            make.width.equalTo(244)
            make.top.equalTo(topLabel.snp.bottom).inset(-15)
            make.centerX.equalToSuperview()
        }
        
        let nextButton = UIButton(type: .system)
        nextButton.backgroundColor = .red
        nextButton.setTitle("Next", for: .normal)
        nextButton.layer.cornerRadius = 28
        nextButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        nextButton.setTitleColor(.white, for: .normal)
        view.addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        cancellable = nextButton.tapPublisher
            .sink { _ in
                self.tapNextButton()
            }
        
        
    }
    
    func tapNextButton() {
        tap += 1
        
        switch tap {
        case 1:
            topLabel.text = "Tools for accumulation"
            imageView.image = .us2
        case 2:
            topLabel.text = "Create any kind of rest"
            imageView.image = .us3
        case 3:
            self.navigationController?.setViewControllers([TabBarViewController()], animated: true)
        default:
            return
        }
    }
}
