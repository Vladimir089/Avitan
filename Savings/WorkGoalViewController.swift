//
//  WorkGoalViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 24.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class WorkGoalViewController: UIViewController {

    var publisher: PassthroughSubject<Any , Never>?
    
    private var cancellable = [AnyCancellable]()
    
    //old
    var index = 0
    var isNew = true
    
    //ui & info
    private lazy var titleTextField = createTextField()
    private lazy var sumTextField = createTextField()
    private var startDate = Date() //no
    private var endDate = Date()
    private lazy var planArr : [Plan] = []
    
    //other
    private lazy var startDateButton = createButton() //тут берем стринг
    private lazy var endDateButton = createButton()
    
    private lazy var delButton = UIButton(type: .system)
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
        button.setTitle("Save", for: .normal)
        button.alpha = 0.5
        button.isEnabled = false
        button.layer.cornerRadius = 28
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        return button
    }()
    
    
    var collection: UICollectionView?
    lazy var planLabel = createLabel(text: "Accumulation plan")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1)
        createInterface()
        checkIsNew()
    }
    
    private func checkIsNew() {
        if isNew == true {
            let item = goalArr[index]
            titleTextField.text = item.title
            sumTextField.text = "\(item.sum)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            startDate = dateFormatter.date(from: item.startDate) ?? Date()
            endDate = dateFormatter.date(from: item.endDate) ?? Date()
            planArr = item.plan
            checkDate()
        }
    }
    
    private func saveNewGoal() {
        let title: String = titleTextField.text ?? ""
        let sum: Double = Double(sumTextField.text ?? "1") ?? 0
        let startDate: String = startDateButton.titleLabel?.text ?? ""
        let endDate: String = endDateButton.titleLabel?.text ?? ""
        
        let plan = Goal(title: title, sum: sum, startDate: startDate, endDate: endDate, plan: planArr)
        goalArr.append(plan)
        saveCode()
    }
    
    private func saveCode() {
        do {
            let data = try JSONEncoder().encode(goalArr) //тут мкассив конвертируем в дату
            try saveAthleteArrToFile(data: data)
            publisher?.send(0)
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
    
    private func saveAthleteArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("goal11.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }

    private func createInterface() {
        let toplabel = UILabel()
        toplabel.text = "Goal"
        toplabel.textColor = .white
        toplabel.font = .systemFont(ofSize: 34, weight: .bold)
        view.addSubview(toplabel)
        toplabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        let backButton = UIButton(type: .system)
        backButton.setBackgroundImage(.backButton, for: .normal)
        view.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalTo(toplabel)
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
        delButton.isHidden = isNew ? true : false
        
        view.addSubview(delButton)
        delButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalTo(toplabel)
            make.height.equalTo(44)
            make.width.equalTo(40)
        }
        
        let titleLabel = createLabel(text: "Title")
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(toplabel.snp.bottom).inset(-20)
        }
        
        view.addSubview(titleTextField)
        titleTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(titleLabel.snp.bottom).inset(-15)
        }
        
        let sumLabel = createLabel(text: "Sum")
        view.addSubview(sumLabel)
        sumLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(titleTextField.snp.bottom).inset(-20)
        }
        
        sumTextField.keyboardType = .decimalPad
        view.addSubview(sumTextField)
        sumTextField.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(46)
            make.top.equalTo(sumLabel.snp.bottom).inset(-15)
        }
        
        let hideKBGesture = UITapGestureRecognizer(target: self, action: nil)
        view.addGestureRecognizer(hideKBGesture)
        hideKBGesture.tapPublisher
            .sink { _ in
                self.view.endEditing(true)
            }
            .store(in: &cancellable)
        
        let startDateLabel = createLabel(text: "Start date")
        view.addSubview(startDateLabel)
        startDateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(sumTextField.snp.bottom).inset(-20)
        }
        
        let stringDate = dateFormatter(date: Date())
        
        
        startDateButton.setTitle(stringDate, for: .normal)
        view.addSubview(startDateButton)
        startDateButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(startDateLabel)
            make.height.equalTo(34)
        }
        
        startDateButton.tapPublisher
            .sink { _ in
                self.openDatePicker(button: self.startDateButton)
            }
            .store(in: &cancellable)
        
        let endDateLabel = createLabel(text: "End date list")
        view.addSubview(endDateLabel)
        endDateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(startDateLabel.snp.bottom).inset(-30)
        }
        
        endDateButton.setTitle(stringDate, for: .normal)
        view.addSubview(endDateButton)
        endDateButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(15)
            make.centerY.equalTo(endDateLabel)
            make.height.equalTo(34)
        }
        endDateButton.tapPublisher
            .sink { _ in
                self.openDatePicker(button: self.endDateButton)
            }
            .store(in: &cancellable)
        
        view.addSubview(planLabel)
        planLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(15)
            make.top.equalTo(endDateLabel.snp.bottom).inset(-20)
        }
        planLabel.alpha = 0
        
        collection = {
            let layout = UICollectionViewFlowLayout()
            let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collection.register(SavingsCollectionViewCell.self, forCellWithReuseIdentifier: "1")
            layout.scrollDirection = .horizontal
            collection.showsHorizontalScrollIndicator = false
            collection.backgroundColor = .clear
            collection.alpha = 0
            collection.delegate = self
            collection.dataSource = self
            return collection
        }()
        view.addSubview(collection!)
        collection?.snp.makeConstraints({ make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(88)
            make.top.equalTo(planLabel.snp.bottom).inset(-10)
        })
        
        view.addSubview(saveButton)
        saveButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(56)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(15)
        }
        
        saveButton.tapPublisher
            .sink { _ in
                self.saveNewGoal()
            }
            .store(in: &cancellable)
    }
    
    private func checkButton() {
        if titleTextField.text?.count ?? 0 > 0 , sumTextField.text?.count ?? 0 > 0 , planArr.count > 0 {
            saveButton.backgroundColor = .red
            saveButton.alpha = 1
            saveButton.isEnabled = true
        } else {
            saveButton.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1)
            saveButton.alpha = 0.5
            saveButton.isEnabled = false
        }
    }
    
    private func checkDate() {
        planArr.removeAll()
        
        let calendar = Calendar.current
        let sum: Double = Double(sumTextField.text ?? "1") ?? 1
        
        
        if startDate < endDate && (startDate != Date() || endDate != Date()) && startDate != endDate {
            collection?.alpha = 1
            
            print(startDate)
            print(endDate)
            
            let components = calendar.dateComponents([.month], from: startDate, to: endDate)
            let months = components.month ?? 1
            
            let monthlyAmount = sum / Double(months)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            
            for monthIndex in 0..<months {
                if let currentMonth = calendar.date(byAdding: .month, value: monthIndex, to: startDate) {
                    let formattedDate = dateFormatter.string(from: currentMonth)
                    let plan = Plan(count: monthlyAmount, date: formattedDate)
                    planArr.append(plan)
                }
            }
            collection?.reloadData()
            checkButton()
            planLabel.alpha = planArr.count > 0 ? 1 : 0
        }
    }
    
    private func dateFormatter(date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
    
    private func openDatePicker(button: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        let containerView = UIView()
        containerView.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            //make.height.equalTo(200)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { [self] _ in
            let selectedDate = datePicker.date
            
            let stringDate = self.dateFormatter(date: selectedDate)
            
            button.setTitle(stringDate, for: .normal)
            
            if button == startDateButton {
                startDate = selectedDate
            } else {
                endDate = selectedDate
            }
            checkDate()
        }))
        
        alertController.view.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.equalTo(alertController.view.snp.top)
            make.left.equalTo(alertController.view.snp.left).offset(10)
            make.right.equalTo(alertController.view.snp.right).offset(-10)
        }
        
        alertController.view.snp.makeConstraints { make in
            make.height.equalTo(250)
        }
        self.present(alertController, animated: true)
    }
    
    

    
    private func createButton() -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.12)
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        return button
    }
    
    private func createTextField() -> UITextField {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 23
        textField.textColor = .red
        textField.delegate = self
        textField.font = .systemFont(ofSize: 17, weight: .semibold)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightViewMode = .always
        textField.leftViewMode = .always
        return textField
    }
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.text = text
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }

}

extension WorkGoalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return planArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "1", for: indexPath) as? SavingsCollectionViewCell
        
        let item = planArr[indexPath.row]
        
        cell?.configure(summ: String(format: "%.3f", item.count), date: item.date)
        
        
        return cell ?? UICollectionViewCell()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 158, height: collectionView.bounds.height)
    }
    
}


extension WorkGoalViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == sumTextField {
            checkDate()
        }
        checkButton()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        checkButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkButton()
        view.endEditing(true)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkButton()
    }
    
}
