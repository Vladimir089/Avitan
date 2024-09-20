//
//  ProfileEditViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 20.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class ProfileEditViewController: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate  {
    
    lazy var profileImageView = UIImageView()
    lazy var ageTextField = UITextField()
    lazy var countryTextField = UITextField()
    lazy var nameTextField = UITextField()
    
    lazy var topLabel = UILabel()
    
    lazy var saveButton = UIButton(type: .system)
    lazy var backButton = UIButton(type: .system)
    
    
    var cancellables = [AnyCancellable]()
    var userNew: User?
    
    var userPublisher: PassthroughSubject<User, Never>?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        createLoginUser()
        checkNew()
    }
    

    func createLoginUser() {
        topLabel.text = "Welcome!"
        topLabel.textColor = .white
        topLabel.font = .systemFont(ofSize: 34, weight: .bold)
        
        view.addSubview(topLabel)
        topLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        profileImageView.image = .user
        profileImageView.layer.cornerRadius = 73
        profileImageView.clipsToBounds = true
        profileImageView.isUserInteractionEnabled = true
        view.addSubview(profileImageView)
        profileImageView.snp.makeConstraints { make in
            make.height.width.equalTo(146)
            make.centerX.equalToSuperview()
            make.top.equalTo(topLabel.snp.bottom).inset(-30)
        }
        let gesture = UITapGestureRecognizer(target: self, action: nil)
        profileImageView.addGestureRecognizer(gesture)
        gesture.tapPublisher
            .sink { _ in
                self.setImage()
            }
            .store(in: &cancellables)
        
        let photoLabel = UILabel()
        photoLabel.text = "Your photo"
        photoLabel.textColor = .white
        photoLabel.font = .systemFont(ofSize: 16, weight: .bold)
        view.addSubview(photoLabel)
        photoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageView.snp.bottom).inset(-15)
        }
        
        let ageLabel = createLabel(text: "Age")
        view.addSubview(ageLabel)
        ageLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(photoLabel.snp.bottom).inset(-15)
        }
        
        ageTextField = createTextField()
        ageTextField.keyboardType = .numberPad
        view.addSubview(ageTextField)
        ageTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(ageLabel.snp.bottom).inset(-10)
        }
        
        let countryLabel = createLabel(text: "Country")
        view.addSubview(countryLabel)
        countryLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(ageTextField.snp.bottom).inset(-10)
        }
        
        countryTextField = createTextField()
        view.addSubview(countryTextField)
        countryTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(countryLabel.snp.bottom).inset(-10)
        }
        
        let nameLabel = createLabel(text: "Name")
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(countryTextField.snp.bottom).inset(-10)
        }
        nameTextField = createTextField()
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(nameLabel.snp.bottom).inset(-10)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(tapGesture)
        tapGesture.tapPublisher
            .sink { compl in
                self.checkButton()
                self.view.endEditing(true)
            }
            .store(in: &cancellables)
        
        saveButton.setTitle("Save", for: .normal)
        saveButton.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        saveButton.layer.cornerRadius = 28
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.isEnabled = false
        saveButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        saveButton.alpha = 0.5
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).inset(-15)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(56)
        }
        saveButton.tapPublisher
            .sink { _ in
                let image = self.profileImageView.image?.jpegData(compressionQuality: 1)
                let age:String = self.ageTextField.text ?? ""
                let country: String = self.countryTextField.text ?? ""
                let name:String = self.nameTextField.text ?? ""
                
                let user = User(image: image ?? Data(), name: name, age: age, countru: country)
                
                do {
                    let data = try JSONEncoder().encode(user)
                    try self.saveAthleteArrToFile(data: data)
                    self.userPublisher?.send(user)
                    self.navigationController?.popToRootViewController(animated: true)
                } catch {
                    print("Failed to encode or save athleteArr: \(error)")
                }
            }
            .store(in: &cancellables)

        backButton.setBackgroundImage(.backButton, for: .normal)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.centerY.equalTo(topLabel)
            make.left.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(75)
        }
        backButton.isHidden = true
        backButton.tapPublisher
            .sink { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    func saveAthleteArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("user.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    func checkButton() {
        if profileImageView.image != .user , ageTextField.text?.count ?? 0 > 0, countryTextField.text?.count ?? 0 > 0 , nameTextField.text?.count ?? 0 > 0 {
            saveButton.backgroundColor = .red
            saveButton.isEnabled = true
            saveButton.alpha = 1
        } else {
            saveButton.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
            saveButton.isEnabled = false
            saveButton.alpha = 0.5
        }
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
        textField.placeholder = "0"
        textField.delegate = self
        textField.textColor = .red
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightViewMode = .always
        textField.leftViewMode = .always
        return textField
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
             profileImageView.layer.borderColor = UIColor.red.cgColor
             profileImageView.layer.borderWidth = 5
             self.checkButton()
         }
     }
     
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true, completion: nil)
     }
    
    func checkNew() {
        if userNew != nil {
            topLabel.text = "Edit"
            profileImageView.image = UIImage(data: userNew?.image ?? Data())
            ageTextField.text = userNew?.age
            countryTextField.text = userNew?.countru
            nameTextField.text = userNew?.name
            profileImageView.layer.borderColor = UIColor.red.cgColor
            profileImageView.layer.borderWidth = 5
            backButton.isHidden = false
        }
    }
     
     

}


extension ProfileEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        checkButton()
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == countryTextField || textField == nameTextField {
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -250)
                
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
              self.view.transform = .identity
          }
    }
}
