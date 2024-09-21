//
//  AddAndEditCategoryViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 20.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class AddAndEditCategoryViewController: UIViewController {
    
    var categoryPublisher: PassthroughSubject<Any, Never>?
    var cancellables = [AnyCancellable]()
    
    var isNew = true
    
    //ui
    lazy var categoryImageView = UIImageView()
    lazy var nameTextField = UITextField()
    lazy var descriptionTextView = UITextView()
    
    //other
    lazy var emojiTextField = EmojiTextField()
    lazy var saveButton = UIButton(type: .system)
    
    //del and edit
    var index = 0
    lazy var delButton = UIButton(type: .system)
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        createInterface()
        checkIsNew()
    }
    
    func checkIsNew() {
        if isNew == false {
            delButton.alpha = 1
            categoryImageView.image = UIImage(data: categoryArr[index].image)
            nameTextField.text = categoryArr[index].name
            descriptionTextView.text = categoryArr[index].description
            checkButton()
        }
    }

    func createInterface() {
        
        let topLabel = UILabel()
        topLabel.text = "Category"
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 34, weight: .bold)
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        }
        
        let backButt = UIButton(type: .system)
        backButt.setBackgroundImage(.backButton, for: .normal)
        view.addSubview(backButt)
        backButt.snp.makeConstraints { make in
            make.centerY.equalTo(topLabel)
            make.left.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(75)
        }
        backButt.tapPublisher
            .sink { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            .store(in: &cancellables)
        
        delButton.setBackgroundImage(.delCategory, for: .normal)
        delButton.alpha = 0
        view.addSubview(delButton)
        delButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(topLabel)
            make.height.equalTo(44)
            make.width.equalTo(40)
        }
        
        delButton.tapPublisher
            .sink { _ in
                let alertController = UIAlertController(title: "Do you want to delete the category?", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                let delAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                    categoryArr.remove(at: self.index)
                    do {
                        let data = try JSONEncoder().encode(categoryArr) //тут мкассив конвертируем в дату
                        try self.saveAthleteArrToFile(data: data)
                        self.categoryPublisher?.send(0)
                        self.navigationController?.popViewController(animated: true)
                    } catch {
                        print("Failed to encode or save athleteArr: \(error)")
                    }
                }
                alertController.addAction(cancelAction)
                alertController.addAction(delAction)
                self.present(alertController, animated: true)
            }
            .store(in: &cancellables)
        
        categoryImageView.layer.cornerRadius = 73
        categoryImageView.clipsToBounds = true
        categoryImageView.isUserInteractionEnabled = true
        view.addSubview(categoryImageView)
        categoryImageView.snp.makeConstraints { make in
            make.height.width.equalTo(146)
            make.centerX.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-30)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openEmojiKeyboard))
        categoryImageView.addGestureRecognizer(tapGesture)
        
        emojiTextField.isHidden = true
        view.addSubview(emojiTextField)
        
        emojiTextField.textPublisher
            .sink { [weak self] text in
                let emojiImage = self?.createEmojiImage(from: String(text ?? ""), size: 40)
                self?.categoryImageView.image = emojiImage
                self?.checkButton()
            }
            .store(in: &cancellables)
        
        let hideGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(hideGesture)
        hideGesture.tapPublisher
            .sink { _ in
                self.view.endEditing(true)
            }
            .store(in: &cancellables)
        
        categoryImageView.image = .user
        
        let photoLabel = UILabel()
        photoLabel.text = "Icon category"
        photoLabel.textColor = .white
        photoLabel.font = .systemFont(ofSize: 16, weight: .bold)
        view.addSubview(photoLabel)
        photoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categoryImageView.snp.bottom).inset(-15)
        }
        
        let nameLabel = createLabel(text: "Name")
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(photoLabel.snp.bottom).inset(-15)
        }
        
        nameTextField = createTextField()
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(nameLabel.snp.bottom).inset(-10)
        }
        
        let deskLabel = createLabel(text: "Description")
        view.addSubview(deskLabel)
        deskLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(nameTextField.snp.bottom).inset(-15)
        }
        
        descriptionTextView.layer.cornerRadius = 20
        descriptionTextView.backgroundColor = .white
        descriptionTextView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        descriptionTextView.textColor = .red
        descriptionTextView.font = .systemFont(ofSize: 17, weight: .semibold)
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.delegate = self
        view.addSubview(descriptionTextView)
        descriptionTextView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(160)
            make.top.equalTo(deskLabel.snp.bottom).inset(-10)
        }
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.layer.cornerRadius = 28
        saveButton.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.alpha = 0.5
        saveButton.isEnabled = false
        saveButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
        }
        saveButton.tapPublisher
            .sink { _ in
                let image: Data = self.categoryImageView.image?.jpegData(compressionQuality: 1) ?? Data()
                let name: String = self.nameTextField.text ?? ""
                let desk: String = self.descriptionTextView.text ?? ""
                
                let category = Category(image: image, name: name, description: desk)
                
                if self.isNew == true {
                    categoryArr.append(category)
                } else {
                    categoryArr[self.index] = category
                }
                
                do {
                    let data = try JSONEncoder().encode(categoryArr) //тут мкассив конвертируем в дату
                    try self.saveAthleteArrToFile(data: data)
                    self.categoryPublisher?.send(0)
                    self.navigationController?.popViewController(animated: true)
                } catch {
                    print("Failed to encode or save athleteArr: \(error)")
                }
                
            }
            .store(in: &cancellables)
        
    }
    
    func saveAthleteArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("category111.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    func checkButton() {
        if categoryImageView.image != .user, nameTextField.text?.count ?? 0 > 0 , descriptionTextView.text.count > 0 {
            saveButton.alpha = 1
            saveButton.isEnabled = true
            saveButton.backgroundColor = UIColor(red: 239/255, green: 26/255, blue: 51/255, alpha: 1)
        } else {
            saveButton.alpha = 0.5
            saveButton.isEnabled = false
            saveButton.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        }
    }
    
    @objc func openEmojiKeyboard() {
        emojiTextField.becomeFirstResponder()
    }
    
    func createEmojiImage(from emoji: String, size: CGFloat) -> UIImage? {
        let label = UILabel()
        label.text = emoji
        label.font = UIFont.systemFont(ofSize: size - 60) // Подстраиваем размер шрифта
        label.backgroundColor = .white
        label.textAlignment = .center
        label.frame = CGRect(x: 0, y: 0, width: size, height: size) // Устанавливаем размер метки
        
        // Определим размер квадрата для эмодзи
        let imageSize = CGSize(width: size, height: size)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Задаем фон для контекста
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: imageSize))
        
        // Рендерим слой метки
        label.layer.render(in: context)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
        textField.layer.cornerRadius = 23
        textField.delegate = self
        textField.textColor = .red
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightViewMode = .always
        textField.leftViewMode = .always
        return textField
    }
    
    
}

extension AddAndEditCategoryViewController: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        checkButton()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        checkButton()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkButton()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkButton()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkButton()
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        checkButton()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        checkButton()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.3) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -250)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkButton()
        UIView.animate(withDuration: 0.3) {
              self.view.transform = .identity
          }
    }
}

class EmojiTextField: UITextField {
    override var textInputMode: UITextInputMode? {
        .activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
    }
}
