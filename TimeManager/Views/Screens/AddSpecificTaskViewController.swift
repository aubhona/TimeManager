//
//  AddSpecificTaskViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 15.03.2024.
//

import UIKit

final class AddSpecificTaskViewController: UIViewController {
    private var titleLabel: UILabel = UILabel()
    private var nameLabel: UILabel = UILabel()
    private var nameTextField: UITextField = UITextField()
    private var descriptionLabel: UILabel = UILabel()
    private var descriptionTextView: UITextView = UITextView()
    private var dateTimePickerLabel: UILabel = UILabel()
    private var scheduledDatePicker = UIDatePicker()
    private var durationLabel: UILabel = UILabel()
    private var durationHourTextField: UITextField = UITextField()
    private var durationHourLabel: UILabel = UILabel()
    private var durationMinuteLabel: UILabel = UILabel()
    private var durationMinuteTextField: UITextField = UITextField()
    private var saveButton: UIButton = UIButton(type: .system)
    
    private var presenter: AddSpecificTaskPresenter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(customBackTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = .red
        configureViews()
        presenter = AddSpecificTaskPresenter(self, CoreDataSpecificTaskRepository.shared)
    }
    
    @objc func customBackTapped() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    private func configureViews() {
        view.addSubview(titleLabel)
        titleLabel.setWidth(view.bounds.width)
        titleLabel.pinTop(to: view.safeAreaLayoutGuide.topAnchor)
        titleLabel.pinLeft(to: view, 30)
        titleLabel.text = "Конкретная задача"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        view.addSubview(nameLabel)
        nameLabel.setWidth(view.bounds.width)
        nameLabel.pinTop(to: titleLabel.bottomAnchor, 10)
        nameLabel.pinLeft(to: view, 30)
        nameLabel.text = "Название"
        nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        view.addSubview(nameTextField)
        nameTextField.pinHorizontal(to: view, 30)
        nameTextField.setHeight(40)
        nameTextField.pinTop(to: nameLabel.bottomAnchor, 10)
        nameTextField.backgroundColor = UIColor("f2f2f7")
        nameTextField.layer.cornerRadius = 12
        nameTextField.tintColor = .red
        nameTextField.delegate = self
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: nameTextField.frame.height))
        nameTextField.leftView = paddingView
        nameTextField.leftViewMode = .always
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Введите текст",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        view.addSubview(dateTimePickerLabel)
        dateTimePickerLabel.setWidth(view.bounds.width)
        dateTimePickerLabel.pinTop(to: nameTextField.bottomAnchor, 10)
        dateTimePickerLabel.pinLeft(to: view, 30)
        dateTimePickerLabel.text = "Время и дата"
        dateTimePickerLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        
        view.addSubview(scheduledDatePicker)
        scheduledDatePicker.pinTop(to: dateTimePickerLabel.bottomAnchor, 10)
        scheduledDatePicker.pinLeft(to: view, 30)
        scheduledDatePicker.locale = Locale(identifier: "ru")
        scheduledDatePicker.tintColor = .red
        
        view.addSubview(durationLabel)
        durationLabel.pinTop(to: scheduledDatePicker.bottomAnchor, 10)
        durationLabel.pinLeft(to: view, 30)
        durationLabel.text = "Продолжительность"
        durationLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        view.addSubview(durationHourTextField)
        view.addSubview(durationMinuteTextField)
        view.addSubview(durationHourLabel)
        view.addSubview(durationMinuteLabel)
        durationHourTextField.pinLeft(to: view, 30)
        durationHourTextField.pinTop(to: durationLabel.bottomAnchor, 10)
        durationHourTextField.attributedPlaceholder = NSAttributedString(string: "00",
                                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        durationHourTextField.backgroundColor = UIColor("f2f2f7")
        durationHourTextField.layer.cornerRadius = 5
        durationHourTextField.setHeight(30)
        durationHourTextField.setWidth(30)
        durationHourTextField.contentVerticalAlignment = .center
        durationHourTextField.contentHorizontalAlignment = .center
        durationHourTextField.textAlignment = .center
        durationHourTextField.keyboardType = .numberPad
        durationHourTextField.tintColor = .red
        durationHourTextField.delegate = self
        
        durationHourLabel.pinLeft(to: durationHourTextField.trailingAnchor, 3)
        durationHourLabel.pinVertical(to: durationHourTextField)
        durationHourLabel.text = "ч"
        durationHourLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        durationMinuteTextField.pinLeft(to: durationHourLabel.trailingAnchor, 5)
        durationMinuteTextField.pinVertical(to: durationHourLabel)
        durationMinuteTextField.setHeight(30)
        durationMinuteTextField.setWidth(30)
        durationMinuteTextField.contentVerticalAlignment = .center
        durationMinuteTextField.contentHorizontalAlignment = .center
        durationMinuteTextField.textAlignment = .center
        durationMinuteTextField.keyboardType = .numberPad
        durationMinuteTextField.attributedPlaceholder = NSAttributedString(string: "00",
                                                                           attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        durationMinuteTextField.backgroundColor = UIColor("f2f2f7")
        durationMinuteTextField.layer.cornerRadius = 5
        durationMinuteTextField.tintColor = .red
        durationMinuteTextField.delegate = self
        
        durationMinuteLabel.pinLeft(to: durationMinuteTextField.trailingAnchor, 3)
        durationMinuteLabel.pinVertical(to: durationMinuteTextField)
        durationMinuteLabel.text = "мин"
        durationMinuteLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        view.addSubview(descriptionLabel)
        descriptionLabel.setWidth(view.bounds.width)
        descriptionLabel.pinTop(to: durationMinuteLabel.bottomAnchor, 10)
        descriptionLabel.pinLeft(to: view, 30)
        descriptionLabel.text = "Описание"
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 15)
        
        view.addSubview(descriptionTextView)
        descriptionTextView.pinHorizontal(to: view, 30)
        descriptionTextView.setHeight(100)
        descriptionTextView.pinTop(to: descriptionLabel.bottomAnchor, 10)
        descriptionTextView.backgroundColor = UIColor("f2f2f7")
        descriptionTextView.layer.cornerRadius = 12
        descriptionTextView.tintColor = .red
        descriptionTextView.delegate = self
        descriptionTextView.text = "Введите описание"
        descriptionTextView.textColor = .lightGray
        descriptionTextView.font = nameTextField.font
        
        
        view.addSubview(saveButton)
        saveButton.pinHorizontal(to: view, 70)
        saveButton.setHeight(35)
        saveButton.layer.cornerRadius = 15
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.backgroundColor = .red
        saveButton.pinBottom(to: view.safeAreaLayoutGuide.bottomAnchor, 10)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let taskDescription = descriptionTextView.text, taskDescription != "Введите описание",
              let durationHoursText = durationHourTextField.text, let durationHours = Int64(durationHoursText),
              let durationMinutesText = durationMinuteTextField.text, let durationMinutes = Int64(durationMinutesText) else {
            showAlert(title: "Ошибка ввода", message: "Заполните все поля")
            return
        }
        
        let totalDuration = (durationHours * 60) + durationMinutes
        presenter?.addTask(name: name, description: taskDescription, scheduledDate: scheduledDatePicker.date, duration: totalDuration)
        customBackTapped()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension AddSpecificTaskViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddSpecificTaskViewController: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor != .lightGray {
            return
        }
        descriptionTextView.text = nil
        descriptionTextView.textColor = .black
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if !descriptionTextView.text.isEmpty {
            return
        }
        descriptionTextView.text = "Введите описание"
        descriptionTextView.textColor = .lightGray
    }
}
