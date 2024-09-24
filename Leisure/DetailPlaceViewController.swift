//
//  DetailPlaceViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 24.09.2024.
//

import UIKit
import Combine
import CombineCocoa


class DetailPlaceViewController: UIViewController {
    
    var index: Int
    var place: Place
    var publisher: PassthroughSubject<Any, Never>
    
    var cancellable = [AnyCancellable]()
    
    init(index: Int, place: Place, publisher: PassthroughSubject<Any, Never>) {
        self.index = index
        self.place = place
        self.publisher = publisher
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        createInterface()
    }
    
    func createInterface() {
        let topLabel = UILabel()
        topLabel.text = "Place"
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 34, weight: .bold)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
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
            .store(in: &cancellable)
        
        let delButton = UIButton(type: .system)
        delButton.setBackgroundImage(.delPlace, for: .normal)
        view.addSubview(delButton)
        delButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(40)
            make.right.equalToSuperview()
            make.centerY.equalTo(topLabel)
        }
        delButton.tapPublisher
            .sink { _ in
                self.del()
            }
            .store(in: &cancellable)
        
        let imageView = UIImageView(image: UIImage(data: place.image))
        imageView.layer.cornerRadius = 73
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 5
        imageView.layer.borderColor = UIColor.red.cgColor
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.width.equalTo(146)
            make.centerX.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-15)
        }
        
        let photoLabel = createLabel(text: "Photo")
        photoLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        view.addSubview(photoLabel)
        photoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).inset(-5)
        }
        
        let countyLabel = createLabel(text: "Country")
        view.addSubview(countyLabel)
        countyLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(photoLabel.snp.bottom).inset(-10)
        }
        
        let countryView = createView(text: place.country)
        view.addSubview(countryView)
        countryView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(countyLabel.snp.bottom).inset(-15)
        }
        
        let descriptionLabel = createLabel(text: "Description")
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(countryView.snp.bottom).inset(-20)
        }
        
        let descriptionView = createView(text: place.description)
        view.addSubview(descriptionView)
        descriptionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(descriptionLabel.snp.bottom).inset(-15)
        }
        
        let categoryLabel = createLabel(text: "My category")
        view.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(descriptionView.snp.bottom).inset(-20)
        }
        
        let collection: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.showsHorizontalScrollIndicator = false
            collection.register(PlaceCollectionViewCell.self, forCellWithReuseIdentifier: "1")
            collection.backgroundColor = .clear
            collection.delegate = self
            collection.dataSource = self
            collection.backgroundColor = .clear
            layout.minimumLineSpacing = 6
            layout.minimumInteritemSpacing = 6
            collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.scrollDirection = .horizontal
            return collection
        }()
        view.addSubview(collection)
        collection.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(80)
            make.top.equalTo(categoryLabel.snp.bottom).inset(-15)
        }
        
        
    }
    
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }
    
    func createView(text: String) -> UIView {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 23
        
        let label = UILabel()
        label.textAlignment = .left
        label.text = text
        label.textColor = .red
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
        return view
    }
   

    func del() {
        
        let alertController = UIAlertController(title: "Do you want to delete the place?", message: nil, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "Cancel", style: .cancel)
        let yesAction = UIAlertAction(title: "Delete", style: .destructive) { [self] action in
            placesArr.remove(at: index)
            do {
                let data = try JSONEncoder().encode(placesArr) //тут мкассив конвертируем в дату
                try saveAthleteArrToFile(data: data)
                publisher.send(0)
                self.navigationController?.popViewController(animated: true)
            } catch {
                print("Failed to encode or save athleteArr: \(error)")
            }
        }
        
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true)
    }
    
    func saveAthleteArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("place.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
}

extension DetailPlaceViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return place.cetegory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath) as? PlaceCollectionViewCell
        
        
        cell?.configure(image: UIImage(data: place.cetegory[indexPath.row].image) ?? UIImage())
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 66, height: 66)
    }
    
    
}
