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
    
    var tapPublisher = PassthroughSubject<Int, Never>()
    
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
        subscribeTap()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        remindersArr = loadReminderArrFromFile() ?? []
        placesArr = loadPlaceArrFromFile() ?? []
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
    
    
    
    func subscribeTap() {
        tapPublisher
            .sink { index in
                let vc = ReminderViewController()
                print(index)
                vc.isNew = false
                vc.index = index
                vc.publisher = self.addNewReminderPublisher
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
        reminderView.publisher = tapPublisher
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
                let vc = ReminderViewController()
                vc.isNew = true
                vc.publisher = self.addNewReminderPublisher
                self.navigationController?.pushViewController(vc, animated: true)
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
    
        addNewReminderButton.tapPublisher
            .sink { _ in
                print(1234)
                let vc = ReminderViewController()
                vc.isNew = true
                vc.publisher = self.addNewReminderPublisher
                self.navigationController?.pushViewController(vc, animated: true)
            }
            .store(in: &cancellables)
        
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
            
            addPlaceButton.tapPublisher
                .sink { _ in
                    self.createNewPlace()
                }
                .store(in: &cancellables)
            
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
            make.width.equalTo(30)
            make.height.equalTo(26)
            make.centerY.equalTo(placesLabel)
            make.right.equalToSuperview().inset(15)
        }
        addNewPlaceButton.tapPublisher
            .sink { _ in
                self.createNewPlace()
            }
            .store(in: &cancellables)
        
        collectionPlaces = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .clear
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            layout.scrollDirection = .vertical
            collection.delegate = self
            collection.dataSource = self
            return collection
        }()
        view.addSubview(collectionPlaces!)
        collectionPlaces?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.top.equalTo(placesLabel.snp.bottom).inset(-10)
        })
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
        reminderView.reloadComponents()
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
    
    func createNewPlace() {
        let vc = NewAndEditPlaceViewController()
        vc.placePublisher = addNewPlacePublisher
        vc.isNew = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    func loadReminderArrFromFile() -> [Reminder]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("reminder1.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([Reminder].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    
    func loadPlaceArrFromFile() -> [Place]? {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Unable to get document directory")
            return nil
        }
        let filePath = documentDirectory.appendingPathComponent("place.plist")
        do {
            let data = try Data(contentsOf: filePath)
            let athleteArr = try JSONDecoder().decode([Place].self, from: data)
            return athleteArr
        } catch {
            print("Failed to load or decode athleteArr: \(error)")
            return nil
        }
    }
    
    func openEdit(index: Int, item: Place) {
        let vc = NewAndEditPlaceViewController()
        vc.isNew = false
        vc.itemOld = item
        vc.oldIndx = index
        vc.placePublisher = addNewPlacePublisher
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openDetail(index: Int, item: Place) {
        let vc = DetailPlaceViewController(index: index, place: item, publisher: addNewPlacePublisher)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension LeisureViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placesArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
        cell.subviews.forEach { $0.removeFromSuperview() }
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 14
        
        let imageView = UIImageView(image: UIImage(data: placesArr[indexPath.row].image))
        imageView.layer.cornerRadius = 33
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.red.cgColor
        cell.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(66)
            make.left.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(10)
        }
        
        let countryLabel = UILabel()
        countryLabel.textColor = .black
        countryLabel.textAlignment = .left
        countryLabel.font = .systemFont(ofSize: 22, weight: .bold)
        countryLabel.text = placesArr[indexPath.row].country
        cell.addSubview(countryLabel)
        countryLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-10)
            make.bottom.equalTo(imageView.snp.centerY)
            make.right.equalToSuperview().inset(10)
        }
        
        let deskLabel = UILabel()
        deskLabel.text = placesArr[indexPath.row].description
        deskLabel.textColor = .black
        deskLabel.textAlignment = .left
        deskLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        cell.addSubview(deskLabel)
        deskLabel.snp.makeConstraints { make in
            make.left.equalTo(imageView.snp.right).inset(-10)
            make.top.equalTo(imageView.snp.centerY)
            make.right.equalToSuperview().inset(10)
        }
        
        let categoryArr = placesArr[indexPath.row].cetegory.prefix(4)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        cell.addSubview(stackView)
        
        for i in categoryArr {
            let item = UIImageView(image: UIImage(data: i.image))
            item.layer.cornerRadius = 22
            item.clipsToBounds = true
            item.layer.borderColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1).cgColor
            item.layer.borderWidth = 2
            stackView.addArrangedSubview(item)
        }
        cell.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().inset(10)
            make.height.equalTo(44)
            make.width.equalTo(stackView.subviews.count * 49)
        }
        
        let countView = UIView()
        countView.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        countView.layer.cornerRadius = 22
        cell.addSubview(countView)
        countView.snp.makeConstraints { make in
            make.height.width.equalTo(44)
            make.centerY.equalTo(stackView)
            make.left.equalTo(stackView.snp.right).inset(-5)
        }
        
        let countLabel = UILabel()
        countLabel.textColor = .red
        countLabel.font = .systemFont(ofSize: 15, weight: .bold)
        countLabel.text = "+\(placesArr[indexPath.row].cetegory.count - 4)"
        countView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        countView.alpha = placesArr[indexPath.row].cetegory.count > 4 ? 1 : 0
        
      
        let editButton = UIButton(type: .system)
        editButton.setBackgroundImage(.editPlace, for: .normal)
        cell.addSubview(editButton)
        editButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(22)
            make.width.equalTo(17)
            make.centerY.equalTo(countView)
        }
        editButton.tapPublisher
            .sink { _ in
                self.openEdit(index: indexPath.row, item: placesArr[indexPath.row])
            }
            .store(in: &cancellables)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 146)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openDetail(index: indexPath.row, item: placesArr[indexPath.row])
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
