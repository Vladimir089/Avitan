//
//  LeisureViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 21.09.2024.
//

import UIKit
import Combine
import CombineCocoa

var remindersArr: [Reminder] = []
var placesArr: [Place] = []

class LeisureViewController: UIViewController {
    
    var cancellables = [AnyCancellable]()
    var addNewReminderPublisher = PassthroughSubject<Any, Never>() //напоминания
    var addNewPlacePublisher = PassthroughSubject<Any, Never>() //места
    
    //reminder
    lazy var addButtonNoArr = UIButton(type: .system)
    lazy var addNewReminderButton = UIButton(type: .system)
    lazy var reminderView = ReminderView()
    lazy var placesLabel = UILabel()
    
    //place
    lazy var noPlacesView = UIView()
    var collectionPlaces: UICollectionView?
    lazy var addNewPlaceButton = UIButton(type: .system)
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        remindersArr = loadReminderArrFromFile() ?? []
        createInterface()
        checkReminderArr()
        checkPlacesArr()
        
        addNewReminderPublisher
            .sink { _ in
                self.checkReminderArr()
                self.reminderView.reloadComponents()
            }
            .store(in: &cancellables)
        
        addNewPlacePublisher
            .sink { _ in
                self.checkPlacesArr()
            }
            .store(in: &cancellables)
    }
    

    func createInterface() {
        let remindersLabel = UILabel()
        remindersLabel.textColor = .white
        remindersLabel.text = "Reminders"
        remindersLabel.font = .systemFont(ofSize: 22, weight: .bold)
        view.addSubview(remindersLabel)
        remindersLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        addButtonNoArr.backgroundColor = .red
        addButtonNoArr.setTitle("Add", for: .normal)
        addButtonNoArr.layer.cornerRadius = 28
        addButtonNoArr.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        addButtonNoArr.setTitleColor(.white, for: .normal)
        view.addSubview(addButtonNoArr)
        addButtonNoArr.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(56)
            make.top.equalTo(remindersLabel.snp.bottom).inset(-10)
        }
        addButtonNoArr.tapPublisher
            .sink { _ in
                print("open page to add Reminder")
            }
            .store(in: &cancellables)
        
        addNewReminderButton.setBackgroundImage(.addCategory, for: .normal)
        view.addSubview(addNewReminderButton)
        addNewReminderButton.snp.makeConstraints { make in
            make.width.equalTo(28)
            make.height.equalTo(26)
            make.centerY.equalTo(remindersLabel)
            make.right.equalToSuperview().inset(15)
        }
        
        view.addSubview(reminderView)
        reminderView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(remindersLabel.snp.bottom).inset(-10)
            make.height.equalTo(116)
        }
        
        placesLabel.text = "Places"
        placesLabel.textColor = .white
        placesLabel.font = .systemFont(ofSize: 22, weight: .bold)
        view.addSubview(placesLabel)
        
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
            botLabel.text = "Create your first place"
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
            
            return view
        }()
        
        view.addSubview(noPlacesView)
        noPlacesView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(placesLabel.snp.bottom).inset(-10)
            make.height.equalTo(66)
        }
        
        addNewPlaceButton.setBackgroundImage(.addCategory, for: .normal)
        view.addSubview(addNewPlaceButton)
        addNewPlaceButton.snp.makeConstraints { make in
            make.width.equalTo(28)
            make.height.equalTo(26)
            make.centerY.equalTo(placesLabel)
            make.right.equalToSuperview().inset(15)
        }
    }
    
    func checkReminderArr() {
        if remindersArr.count > 0 {
            addButtonNoArr.alpha = 0
            addNewReminderButton.alpha = 1
            reminderView.alpha = 1
            placesLabel.snp.remakeConstraints({ make in
                make.left.equalToSuperview().inset(15)
                make.top.equalTo(reminderView.snp.bottom).inset(-15)
            })
            view.layoutIfNeeded()
        } else {
            addButtonNoArr.alpha = 1
            addNewReminderButton.alpha = 0
            reminderView.alpha = 0
            placesLabel.snp.remakeConstraints({ make in
                make.left.equalToSuperview().inset(15)
                make.top.equalTo(addButtonNoArr.snp.bottom).inset(-15)
            })
            view.layoutIfNeeded()
        }
    }
    
    
    func checkPlacesArr() {
        if placesArr.count > 0 {
            collectionPlaces?.alpha = 1
            noPlacesView.alpha = 0
            addNewPlaceButton.alpha = 1
            collectionPlaces?.reloadData()
        } else {
            collectionPlaces?.alpha = 0
            noPlacesView.alpha = 1
            addNewPlaceButton.alpha = 0
        }
    }
    
    func loadReminderArrFromFile() -> [Reminder]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("athleteArr.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([Reminder].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    
    
}


struct Reminder: Codable {
    var title: String
    var description: String
    var date: String
    
    init(title: String, description: String, date: String) {
        self.title = title
        self.description = description
        self.date = date
    }
}


struct Place: Codable {
    var image: Data
    var country: String
    var description: String
    var cetegory: [Category]
    var checkList: [CheckList]
    
    init(image: Data, country: String, description: String, cetegory: [Category], checkList: [CheckList]) {
        self.image = image
        self.country = country
        self.description = description
        self.cetegory = cetegory
        self.checkList = checkList
    }
}


struct CheckList: Codable {
    var name: String
    var isComplete: Bool
    
    init(name: String, isComplete: Bool) {
        self.name = name
        self.isComplete = isComplete
    }
}
