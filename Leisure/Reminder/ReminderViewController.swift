//
//  ReminderViewController.swift
//  Avitan
//
//  Created by Владимир Кацап on 24.09.2024.
//

import UIKit
import Combine
import CombineCocoa

class ReminderViewController: UIViewController {
    
    var publisher: PassthroughSubject<Any, Never>?
    lazy var isNew = true
    lazy var cabcellable = [AnyCancellable]()
    
    //old
    lazy var index = 0
    
    //ui
    private lazy var mainView = ReminderMainView(controller: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view = mainView
        checkIsNew()
    }
    
    private func checkIsNew() {
        if isNew == false {
            mainView.isOldComponent(item: remindersArr[index])
        }
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func deleteItem() {
        let alertController = UIAlertController(title: "Do you want to delete the reminder?", message: nil, preferredStyle: .alert)
        let noAction = UIAlertAction(title: "Cancel", style: .cancel)
        let yesAction = UIAlertAction(title: "Delete", style: .destructive) { [self] action in
            remindersArr.remove(at: index)
            saveInFile()
        }
        alertController.addAction(noAction)
        alertController.addAction(yesAction)
        self.present(alertController, animated: true)
    }
    
    
    private func saveInFile() {
        do {
            let data = try JSONEncoder().encode(remindersArr)
            try saveAthleteArrToFile(data: data)
            publisher?.send(0)
            navigationController?.popViewController(animated: true)
        } catch {
            print("Failed to encode or save athleteArr: \(error)")
        }
    }
    
    func createReminder(reminder: Reminder) {
        remindersArr.append(reminder)
        saveInFile()
    }
    
    private func saveAthleteArrToFile(data: Data) throws {
        let fileManager = FileManager.default
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath = documentDirectory.appendingPathComponent("reminder1.plist")
            try data.write(to: filePath)
        } else {
            throw NSError(domain: "SaveError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get document directory"])
        }
    }
    
    
}


