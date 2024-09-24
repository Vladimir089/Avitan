//
//  ReminderView.swift
//  Avitan
//
//  Created by Владимир Кацап on 24.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class ReminderMainView: UIView {
    
    var controller: ReminderViewController
    
    init(controller: ReminderViewController) {
        self.controller = controller
        super.init(frame: .zero)
        createInterface()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: -UI
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(.backButton, for: .normal)
        return button
    }()
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Reminder"
        label.textColor = .white
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var delButton: UIButton = {
        let button = UIButton(type: .system)
        button.setBackgroundImage(.delPlace, for: .normal)
        button.alpha = controller.isNew ? 0 : 1
        return button
    }()
    
    private lazy var titleLabel = createLabel(text: "Title")
    
    private lazy var titleTextField = createTextField()              //title
    
    private lazy var descriptionLabel = createLabel(text: "Description")
    
    private lazy var descriptionTextField = createTextField()         //desk
    
    private lazy var dateLabel = createLabel(text: "Date")
    
    private lazy var dateTextField = createTextField()               //date
    
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.locale = Locale(identifier: "en_US")
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()
    
    private lazy var tapHideKeyboardGesture = UITapGestureRecognizer(target: self, action: nil)
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.layer.cornerRadius = 28
        button.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.isUserInteractionEnabled = false
        button.alpha = controller.isNew ? 0.5 : 0
        return button
    }()
    
    
    //MARK: -Func
    
    func isOldComponent(item: Reminder) {
        titleTextField.text = item.title
        descriptionTextField.text = item.description
        dateTextField.text = item.date
        let arrTextField = [titleTextField, descriptionTextField, dateTextField]
        arrTextField.map({ $0.textColor = .red})
        saveButton.isHidden = true
    }
    
    private func createInterface() {
        backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        
        addSubview(headerLabel)
        headerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top)
        }
        
        addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(headerLabel)
            make.height.equalTo(44)
            make.width.equalTo(75)
        }
        backButton.tapPublisher
            .sink { _ in
                self.controller.goBack()
            }
            .store(in: &controller.cabcellable)
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(headerLabel.snp.bottom).inset(-25)
        }
        
        addSubview(delButton)
        delButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(headerLabel)
            make.height.equalTo(44)
            make.width.equalTo(40)
        }
        delButton.tapPublisher
            .sink { _ in
                self.controller.deleteItem()
            }
            .store(in: &controller.cabcellable)
        
        
        
        addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(66)
            make.top.equalTo(titleLabel.snp.bottom).inset(-10)
        }
        
        addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(titleTextField.snp.bottom).inset(-20)
        }
        
        addSubview(descriptionTextField)
        descriptionTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(66)
            make.top.equalTo(descriptionLabel.snp.bottom).inset(-10)
        }
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(descriptionTextField.snp.bottom).inset(-20)
        }
        
        addSubview(dateTextField)
        dateTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(66)
            make.top.equalTo(dateLabel.snp.bottom).inset(-10)
        }
        
        dateTextField.inputView = datePicker
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        dateTextField.inputAccessoryView = toolbar
        
        addGestureRecognizer(tapHideKeyboardGesture)
        tapHideKeyboardGesture.tapPublisher
            .sink { _ in
                self.checkButton()
                self.endEditing(true)
            }
            .store(in: &controller.cabcellable)

        addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(15)
            make.height.equalTo(56)
        }
        saveButton.tapPublisher
            .sink { _ in
                self.createReminder()
            }
            .store(in: &controller.cabcellable)
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }
    
    private func createTextField() -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 10))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 10))
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.textColor = .black
        textField.isUserInteractionEnabled = controller.isNew ? true : false
        textField.font = .systemFont(ofSize: 17, weight: .semibold)
        textField.layer.cornerRadius = 33
        textField.delegate = self
        return textField
    }
    
    @objc private func dateChanged() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        checkButton()
    }
    
    @objc private func donePressed() {
        dateTextField.resignFirstResponder()
        checkButton()
    }
    
    private func configureButton(isOn: Bool) {
        saveButton.isUserInteractionEnabled = isOn
        saveButton.alpha = isOn ? 1 : 0.5
        saveButton.backgroundColor = isOn ? .red : UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        let arrTextField = [titleTextField, descriptionTextField, dateTextField]
        arrTextField.map({ $0.textColor = isOn ? .red : .black})
    }
    
    private func checkButton() {
        if titleTextField.text?.count ?? 0 > 0 , descriptionTextField.text?.count ?? 0 > 0, dateTextField.text?.count ?? 0 > 0 {
            configureButton(isOn: true)
        } else {
            configureButton(isOn: false)
        }
    }
    
    private func createReminder() {
        let title: String = titleTextField.text ?? ""
        let description: String = descriptionTextField.text ?? ""
        let date: String = dateTextField.text ?? ""
        
        let reminder = Reminder(title: title, description: description, date: date)
        controller.createReminder(reminder: reminder)
    }
    
}


extension ReminderMainView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
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
}
