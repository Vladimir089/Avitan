//
//  SavingsViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 24.09.2024.
//

import UIKit
import Combine
import CombineCocoa

var goalArr: [Goal] = []

class SavingsViewController: UIViewController {
    
    //publisher
    lazy var goalPublisher = PassthroughSubject<Any, Never>()
    
    //other
    var cancellable = [AnyCancellable]()
    
    //ui
    private lazy var addNewGoalButton = UIButton(type: .system)
    private lazy var noPlacesView = UIView()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        createInterface()
        goalArr = loadAthleteArrFromFile() ?? []
        checkArr()
        subscribe()
    }
    
    private func createInterface() {
        let imageViewBG = UIImageView(image: .savingsBG)
        view.addSubview(imageViewBG)
        imageViewBG.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let topLabel = UILabel()
        topLabel.text = "Goals"
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 22, weight: .bold)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        addNewGoalButton.setBackgroundImage(.addCategory, for: .normal)
        view.addSubview(addNewGoalButton)
        addNewGoalButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(topLabel)
            make.height.equalTo(26)
            make.width.equalTo(30)
        }
        addNewGoalButton.tapPublisher
            .sink { _ in
                self.openGoal(isNew: true, index: nil)
            }
            .store(in: &cancellable)
        
        noPlacesView = {
            let view = UIView()
            view.backgroundColor = .clear
            
            let topLabel = UILabel()
            topLabel.text = "Empty"
            topLabel.textColor = .white
            topLabel.font = .systemFont(ofSize: 22, weight: .bold)
            view.addSubview(topLabel)
            topLabel.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.bottom.equalTo(view.snp.centerY)
            }
            
            let botLabel = UILabel()
            botLabel.text = "Create your first goal"
            botLabel.font = .systemFont(ofSize: 17, weight: .bold)
            botLabel.textColor = .white
            view.addSubview(botLabel)
            botLabel.snp.makeConstraints { make in
                make.top.equalTo(view.snp.centerY)
                make.left.equalToSuperview()
            }
            
            let addPlaceButton = UIButton(type: .system)
            addPlaceButton.setBackgroundImage(.addCategoryButton, for: .normal)
            view.addSubview(addPlaceButton)
            addPlaceButton.snp.makeConstraints { make in
                make.height.width.equalTo(66)
                make.centerY.equalToSuperview()
                make.right.equalToSuperview()
            }
            
            addPlaceButton.tapPublisher
                .sink { _ in
                    self.openGoal(isNew: true, index: nil)
                }
                .store(in: &cancellable)
            
            return view
        }()
        view.addSubview(noPlacesView)
        noPlacesView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(66)
            make.top.equalTo(topLabel.snp.bottom).inset(-5)
        }
        
        
    }
    
    private func openGoal(isNew: Bool, index: Int?) {
        let vc = WorkGoalViewController()
        vc.isNew = isNew
        vc.publisher = goalPublisher
        vc.index = index ?? 0
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func subscribe() {
        goalPublisher
            .sink { goal in
                self.checkArr()
                print("реализовать сохранение в файл и создать коллекцию")
            }
            .store(in: &cancellable)
    }
    
    
    
    private func checkArr() {
        if goalArr.count > 0 {
            addNewGoalButton.alpha = 1
            noPlacesView.alpha = 0
        } else {
            addNewGoalButton.alpha = 0
            noPlacesView.alpha = 1
        }
    }
    
    private func loadAthleteArrFromFile() -> [Goal]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("goal11.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([Goal].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    

}




struct Goal: Codable {
    var title: String
    var sum: Double
    var startDate: String
    var endDate: String
    var plan: [Plan]
    
    init(title: String, sum: Double, startDate: String, endDate: String, plan: [Plan]) {
        self.title = title
        self.sum = sum
        self.startDate = startDate
        self.endDate = endDate
        self.plan = plan
    }
}

struct Plan: Codable {
    var count: Double
    var date: String
    
    init(count: Double, date: String) {
        self.count = count
        self.date = date
    }
}
