//
//  LoadViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 20.09.2024.
//

import UIKit
import SnapKit

class LoadViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
        creatInterface()
        timer = Timer.scheduledTimer(withTimeInterval: 0, repeats: false, block: { _ in //7
            if isBet == false {
                if UserDefaults.standard.object(forKey: "tab") != nil {
                    self.navigationController?.setViewControllers([TabBarViewController()], animated: true)
                } else {
                   self.navigationController?.setViewControllers([OnbUserViewController()], animated: true)
                }
            } else {
                if UserDefaults.standard.object(forKey: "Rew") != nil {
                   // self.navigationController?.setViewControllers([WebSiteViewController()], animated: true)
                } else {
                   //self.navigationController?.setViewControllers([RewViewController()], animated: true)
                }
            }
        })
    }
    
    func creatInterface() {
        let imageView = UIImageView()
        imageView.image = .logLoad
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalTo(172)
            make.width.equalTo(233)
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        let label = UILabel()
        label.text = "Avitan"
        label.textColor = .red
        label.font = .systemFont(ofSize: 120, weight: .bold)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(-5)
        }
        
        let loadIndicator = UIActivityIndicatorView(style: .medium)
        loadIndicator.color = .red
        view.addSubview(loadIndicator)
        loadIndicator.snp.makeConstraints { make in
            make.height.width.equalTo(30)
            make.centerX.equalToSuperview().offset(-40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        loadIndicator.startAnimating()
        
        let labelStat = UILabel()
        labelStat.text = "Status..."
        labelStat.textColor = .red
        labelStat.font = .systemFont(ofSize: 17, weight: .regular)
        view.addSubview(labelStat)
        labelStat.snp.makeConstraints { make in
            make.centerY.equalTo(loadIndicator)
            make.left.equalTo(loadIndicator.snp.right).inset(-5)
        }
    }
    

 
}
