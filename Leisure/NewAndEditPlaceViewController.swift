//
//  NewAndEditPlaceViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 23.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class NewAndEditPlaceViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    var placePublisher: PassthroughSubject<Any, Never>?
    var isNew = true 
    
    lazy var cancellables = [AnyCancellable]()
    var itemOld: Place?
    var oldIndx = 0 //идекс при редактировании
    
    //ui
    lazy var topLabel = UILabel()
    var mainCollection: UICollectionView?
    var checkListCollection: UICollectionView?
    lazy var saveButton = UIButton(type: .system)
    
    //elements
    lazy var profileImageView = UIImageView()
    lazy var countryTextField = UITextField()
    lazy var descriptionTextField = UITextField()
    var checkListArr: [CheckList] = []
    var selectedCategoryArr: [Category] = []
    
    //other
    var selectCategoryPablisher = PassthroughSubject<[Category], Never>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        createInterface()
        checkNew()
        subscribeVC()
    }
    
    
    func subscribeVC() {
        selectCategoryPablisher
            .sink { category in
                self.selectedCategoryArr = category
                self.mainCollection?.reloadData()
                self.checkButton()
            }
            .store(in: &cancellables)
    }
    
    func checkNew() {
        if isNew == false {
            countryTextField.text = itemOld?.country
            descriptionTextField.text = itemOld?.description
            selectedCategoryArr = itemOld?.cetegory ?? []
            checkListArr = itemOld?.checkList ?? []
            mainCollection?.reloadData()
            checkListCollection?.reloadData()
        }
    }
    

    func createInterface() {
        topLabel.text = isNew ? "Place" : "Edit"
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
                self.navigationController?.popToRootViewController(animated: true)
            }
            .store(in: &cancellables)
        
        countryTextField = createTextField()
        descriptionTextField = createTextField()
        profileImageView.image = isNew ? .user : UIImage(data: itemOld?.image ?? Data())
        profileImageView.layer.cornerRadius = 73
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = isNew ? 0 : 5
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.borderColor = isNew ? UIColor.white.cgColor : UIColor.red.cgColor
        
        mainCollection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .clear
            collection.showsVerticalScrollIndicator = false
            layout.scrollDirection = .vertical
            collection.delegate = self
            collection.dataSource = self
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "1")
            collection.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
            return collection
        }()
        view.addSubview(mainCollection!)
        mainCollection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-5)
        })
        
        let gestureHideKB = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(gestureHideKB)
        gestureHideKB.tapPublisher
            .sink { _ in
                self.view.endEditing(true)
            }
            .store(in: &cancellables)
        
        checkListCollection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.backgroundColor = .clear
            collection.showsVerticalScrollIndicator = false
            layout.scrollDirection = .vertical
            collection.delegate = self
            collection.dataSource = self
            layout.minimumLineSpacing = 15
            collection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "2")
            return collection
        }()
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 28
        saveButton.isEnabled = false
        saveButton.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        saveButton.alpha = 0.5
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
        }
        saveButton.tapPublisher
            .sink { _ in
                self.savePlace()
            }
            .store(in: &cancellables)
    }
    
    func checkButton() {
        if profileImageView.image != .user , countryTextField.text?.count ?? 0 > 0 , descriptionTextField.text?.count ?? 0 > 0 , selectedCategoryArr.count > 0 , checkListArr.count > 0 {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .red
            saveButton.alpha = 1
        } else {
            saveButton.isEnabled = false
            saveButton.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
            saveButton.alpha = 0.5
        }
    }
    
    func setImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let pickedImage = info[.originalImage] as? UIImage {
            profileImageView.image = pickedImage
            profileImageView.layer.borderWidth = 5
            profileImageView.layer.borderColor = UIColor.red.cgColor
            checkButton()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }
    
    func createTextField() -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.layer.cornerRadius = 23
        textField.delegate = self
        textField.leftView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightViewMode = .always
        textField.leftViewMode = .always
        textField.font = .systemFont(ofSize: 17, weight: .semibold)
        return textField
    }
    
    func addCheckList() {
        let alertController = UIAlertController(title: "Write a task to complete", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "Add", style: .destructive) { action in
            let name:String = alertController.textFields?.first?.text ?? ""
            let check = CheckList(name: name, isComplete: false)
            self.checkListArr.append(check)
            self.mainCollection?.reloadData()
            self.checkListCollection?.reloadData()
            self.checkButton()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    func deltask(index: Int) {
        let alertController = UIAlertController(title: "Do you want to delete the task?", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let okAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.checkListArr.remove(at: index)
            self.mainCollection?.reloadData()
            self.checkListCollection?.reloadData()
            self.checkButton()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    func savePlace() {
        
        let image: Data = profileImageView.image?.jpegData(compressionQuality: 1) ?? Data()
        let country: String = countryTextField.text ?? ""
        let desk: String = descriptionTextField.text ?? ""

        let place = Place(image: image, country: country, description: desk, cetegory: selectedCategoryArr, checkList: checkListArr)
        
        if isNew == true {
            placesArr.append(place)
        } else {
            placesArr[oldIndx] = place
        }
        
        do {
            let data = try JSONEncoder().encode(placesArr) //тут мкассив конвертируем в дату
            try saveAthleteArrToFile(data: data)
            placePublisher?.send(1)
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
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


extension NewAndEditPlaceViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mainCollection {
            return 2
        } else {
            return checkListArr.count > 0 ? checkListArr.count : 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mainCollection {
            let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
            
            if indexPath.row == 0 {
                
                cell.addSubview(profileImageView)
                profileImageView.snp.makeConstraints { make in
                    make.height.width.equalTo(146)
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().inset(10)
                }
                let selectImageGesture = UITapGestureRecognizer(target: self, action: nil)
                profileImageView.addGestureRecognizer(selectImageGesture)
                selectImageGesture.tapPublisher
                    .sink { _ in
                        self.setImage()
                    }
                    .store(in: &cancellables)
                
                let photoLabel = UILabel()
                photoLabel.text = "Photo"
                photoLabel.textColor = .white
                photoLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.addSubview(photoLabel)
                photoLabel.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.top.equalTo(profileImageView.snp.bottom).inset(-10)
                }
                
                let countryLabel = createLabel(text: "Country")
                cell.addSubview(countryLabel)
                countryLabel.snp.makeConstraints { make in
                    make.left.equalToSuperview()
                    make.top.equalTo(photoLabel.snp.bottom).inset(-15)
                }
                
                cell.addSubview(countryTextField)
                countryTextField.snp.makeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.height.equalTo(46)
                    make.top.equalTo(countryLabel.snp.bottom).inset(-10)
                }
                
                let descriptionLabel = createLabel(text: "Desciption")
                cell.addSubview(descriptionLabel)
                descriptionLabel.snp.makeConstraints { make in
                    make.left.equalToSuperview()
                    make.top.equalTo(countryTextField.snp.bottom).inset(-15)
                }
                cell.addSubview(descriptionTextField)
                descriptionTextField.snp.makeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.height.equalTo(46)
                    make.top.equalTo(descriptionLabel.snp.bottom).inset(-10)
                }
                
                let categoryLabel = createLabel(text: "My category")
                cell.addSubview(categoryLabel)
                categoryLabel.snp.makeConstraints { make in
                    make.left.equalToSuperview()
                    make.top.equalTo(descriptionTextField.snp.bottom).inset(-15)
                }
                
                let addCategoryButton = UIButton(type: .system)
                addCategoryButton.setBackgroundImage(.addCategoryButton, for: .normal)
                cell.addSubview(addCategoryButton)
                addCategoryButton.snp.makeConstraints { make in
                    make.right.equalToSuperview()
                    make.height.width.equalTo(66)
                    make.top.equalTo(categoryLabel.snp.bottom).inset(-10)
                }
                addCategoryButton.tapPublisher
                    .sink { _ in
                        let vc = SelectCategoryViewController()
                        vc.categories = self.selectedCategoryArr
                        vc.selectCategoryPablisher = self.selectCategoryPablisher
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    .store(in: &cancellables)
                
                let noCategoryView = {
                    let view = UIView()
                    view.backgroundColor = .clear
                    let topLabel = createLabel(text: "Empty")
                    view.addSubview(topLabel)
                    topLabel.snp.makeConstraints { make in
                        make.left.equalToSuperview()
                        make.bottom.equalTo(view.snp.centerY)
                    }
                    
                    let botView = createLabel(text: "Select category")
                    botView.font = .systemFont(ofSize: 17, weight: .bold)
                    view.addSubview(botView)
                    botView.snp.makeConstraints { make in
                        make.left.equalToSuperview()
                        make.top.equalTo(view.snp.centerY)
                    }
                    return view
                }()
                noCategoryView.alpha = selectedCategoryArr.count > 0 ? 0 : 1
                cell.addSubview(noCategoryView)
                noCategoryView.snp.makeConstraints { make in
                    make.left.equalToSuperview()
                    make.height.equalTo(66)
                    make.centerY.equalTo(addCategoryButton)
                    make.right.equalTo(addCategoryButton.snp.left).inset(-10)
                }
                
                let countView: UIView = {
                    let view = UIView()
                    view.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
                    view.layer.cornerRadius = 33
                    let label = UILabel()
                    label.text = "+\(selectedCategoryArr.count - 3)"
                    label.textColor = .red
                    label.font = .systemFont(ofSize: 22, weight: .bold)
                    view.addSubview(label)
                    label.snp.makeConstraints { make in
                        make.center.equalToSuperview()
                    }
                    view.alpha = 0
                    return view
                }()
                cell.addSubview(countView)
                countView.snp.makeConstraints { make in
                    make.height.width.equalTo(66)
                    make.centerY.equalTo(addCategoryButton)
                    make.right.equalTo(addCategoryButton.snp.left).inset(-5)
                }
                
                let stackView = UIStackView()
                stackView.axis = .horizontal
                stackView.alpha = 0
                stackView.spacing = 7
                cell.addSubview(stackView)
                stackView.snp.makeConstraints { make in
                    make.left.equalToSuperview()
                    make.right.equalTo(countView.snp.left).inset(-5)
                    make.height.equalTo(66)
                    make.centerY.equalTo(addCategoryButton)
                }

                stackView.alignment = .center
                //stackView.distribution = .fillProportionally
                
                if selectedCategoryArr.count > 3 {
                    stackView.alpha = 1
                    countView.alpha = 1
                } else {
                    stackView.alpha = 1
                    countView.alpha = 0
                }
                
                for i in selectedCategoryArr {
                    if stackView.arrangedSubviews.count < 3 {
                        let imageView = UIImageView(image: UIImage(data: i.image))
                        imageView.layer.cornerRadius = 33
                        imageView.clipsToBounds = true
                        
                        stackView.addArrangedSubview(imageView)
                        
                        
                        imageView.snp.makeConstraints { make in
                               make.width.height.equalTo(66) // Размер 66x66
                           }
                        
                    }
                }
                
                switch stackView.arrangedSubviews.count {
                case 1:
                    stackView.snp.remakeConstraints { make in
                        make.left.equalToSuperview()
                        make.width.equalTo(66)
                        make.height.equalTo(66)
                        make.centerY.equalTo(addCategoryButton)
                    }
                case 2 :
                    stackView.snp.remakeConstraints { make in
                        make.left.equalToSuperview()
                        make.width.equalTo(142)
                        make.height.equalTo(66)
                        make.centerY.equalTo(addCategoryButton)
                    }
                case 3:
                    stackView.snp.remakeConstraints { make in
                        make.left.equalToSuperview()
                        make.right.equalTo(countView.snp.left).inset(-5)
                        make.height.equalTo(66)
                        make.centerY.equalTo(addCategoryButton)
                    }
                default:
                    break
                }
                
                let checkListLabel = createLabel(text: "Check list")
                cell.addSubview(checkListLabel)
                checkListLabel.snp.makeConstraints { make in
                    make.left.equalToSuperview()
                    make.top.equalTo(stackView.snp.bottom).inset(-15)
                }
                //cell.backgroundColor = .orange
                
                let addCheckListButton = UIButton(type: .system)
                addCheckListButton.setBackgroundImage(.addCategory, for: .normal)
                cell.addSubview(addCheckListButton)
                addCheckListButton.snp.makeConstraints { make in
                    make.right.equalToSuperview()
                    make.centerY.equalTo(checkListLabel)
                    make.height.equalTo(23)
                    make.width.equalTo(25)
                }
                addCheckListButton.alpha = checkListArr.count > 0 ? 1 : 0
                addCheckListButton.tapPublisher
                    .sink { _ in
                        self.addCheckList()
                    }
                    .store(in: &cancellables)
            } else {
                if checkListArr.count > 0 {
                    cell.addSubview(checkListCollection!)
                    checkListCollection?.snp.makeConstraints({ make in
                        make.left.right.top.bottom.equalToSuperview()
                    })
                } else {
                    let addCategoryButton = UIButton(type: .system)
                    addCategoryButton.setBackgroundImage(.addCategoryButton, for: .normal)
                    cell.addSubview(addCategoryButton)
                    addCategoryButton.snp.makeConstraints { make in
                        make.right.equalToSuperview()
                        make.height.width.equalTo(66)
                        make.top.equalToSuperview()
                    }
                    addCategoryButton.tapPublisher
                        .sink { _ in
                            self.addCheckList()
                        }
                        .store(in: &cancellables)
                    
                    let noCategoryView = {
                        let view = UIView()
                        view.backgroundColor = .clear
                        let topLabel = createLabel(text: "Empty")
                        view.addSubview(topLabel)
                        topLabel.snp.makeConstraints { make in
                            make.left.equalToSuperview()
                            make.bottom.equalTo(view.snp.centerY)
                        }
                        
                        let botView = createLabel(text: "Add check list")
                        botView.font = .systemFont(ofSize: 17, weight: .bold)
                        view.addSubview(botView)
                        botView.snp.makeConstraints { make in
                            make.left.equalToSuperview()
                            make.top.equalTo(view.snp.centerY)
                        }
                        return view
                    }()
                    noCategoryView.alpha = checkListArr.count > 0 ? 0 : 1
                    cell.addSubview(noCategoryView)
                    noCategoryView.snp.makeConstraints { make in
                        make.left.equalToSuperview()
                        make.height.equalTo(66)
                        make.centerY.equalTo(addCategoryButton)
                        make.right.equalTo(addCategoryButton.snp.left).inset(-10)
                    }
                    //cell.backgroundColor = .orange
                }
            }
            
            return cell
        } else {
            let  cell = collectionView.dequeueReusableCell(withReuseIdentifier: "2", for: indexPath)
            cell.subviews.forEach { $0.removeFromSuperview() }
            cell.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
            
            let delButton = UIButton(type: .system)
            delButton.setBackgroundImage(.delCheck, for: .normal)
            cell.addSubview(delButton)
            delButton.snp.makeConstraints { make in
                make.height.width.equalTo(22)
                make.right.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            delButton.tapPublisher
                .sink { _ in
                    self.deltask(index: indexPath.row)
                }
                .store(in: &cancellables)
            
            let mainView = UIView()
            mainView.backgroundColor = .white
            mainView.layer.cornerRadius = 23
            cell.addSubview(mainView)
            mainView.snp.makeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.right.equalTo(delButton.snp.left).inset(-15)
            }
            
            let imageView = UIImageView()
            imageView.image = checkListArr[indexPath.row].isComplete ? .okCheckList : .noCheckList
            mainView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalTo(22)
                make.left.equalToSuperview().inset(20)
                make.centerY.equalToSuperview()
                make.height.equalTo(checkListArr[indexPath.row].isComplete ? 45 : 22)
            }
            let label = UILabel()
            label.text = checkListArr[indexPath.row].name
            label.textColor = .red
            label.font = .systemFont(ofSize: 17, weight: .regular)
            mainView.addSubview(label)
            label.snp.makeConstraints { make in
                make.right.equalToSuperview().inset(15)
                make.left.equalTo(imageView.snp.right).inset(-15)
                make.centerY.equalToSuperview()
            }
            if checkListArr[indexPath.row].isComplete { // Например, если элемент отмечен
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: checkListArr[indexPath.row].name)
                attributeString.addAttribute(.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length)) // Добавляем зачёркивание
                label.attributedText = attributeString
            } else {
                label.text = checkListArr[indexPath.row].name // Если не зачёркнут
            }
            
            let gesture = UITapGestureRecognizer(target: self, action: nil)
            mainView.addGestureRecognizer(gesture)
            gesture.tapPublisher
                .sink { tap in
                    self.checkListArr[indexPath.row].isComplete = self.checkListArr[indexPath.row].isComplete ? false : true
                    self.checkListCollection?.reloadData()
                    self.checkButton()
                }
                .store(in: &cancellables)
            
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == mainCollection {
            if indexPath.row == 0 {
                return CGSize(width: collectionView.frame.width, height: 550)
            } else {
                return CGSize(width: collectionView.frame.width, height: checkListArr.count > 0 ? CGFloat((61 * checkListArr.count)) : 66)
            }
        } else {
            return CGSize(width: collectionView.frame.width, height:  checkListArr.count > 0 ? 46 : 66)
        }
    }
    
}


extension NewAndEditPlaceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkButton()
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        checkButton()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkButton()
        return true
    }
}

