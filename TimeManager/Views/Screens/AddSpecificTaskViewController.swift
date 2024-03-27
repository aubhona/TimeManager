//
//  AddSpecificTaskViewController.swift
//  TimeManager
//
//  Created by Aubkhon Abdullaev on 15.03.2024.
//

import UIKit

internal final class AddSpecificTaskViewController: UIViewController {
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
    private var addReminderButton: UIButton = UIButton()
    private var addCalendarButton: UIButton = UIButton()
    private var tagsCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var tagLabel: UILabel = UILabel()
    private var addTagButton: UIButton = UIButton(type: .system)
    
    private var presenter: AddSpecificTaskPresenter?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(customBackTapped))
        self.navigationItem.leftBarButtonItem?.tintColor = .red
        configureViews()
        presenter = AddSpecificTaskPresenter(self, CoreDataSpecificTaskRepository.shared, ReminderManager(), CalendarManager(), CoreDataTagRepository.shared)
    }
    
    @objc private func customBackTapped() {
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
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
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
        dateTimePickerLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        
        view.addSubview(scheduledDatePicker)
        scheduledDatePicker.pinTop(to: dateTimePickerLabel.bottomAnchor, 10)
        scheduledDatePicker.pinLeft(to: view, 30)
        scheduledDatePicker.locale = Locale(identifier: "ru")
        scheduledDatePicker.tintColor = .red
        
        addCalendarButton.setImage(UIImage(systemName: "square"), for: .normal)
        addCalendarButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        addCalendarButton.setTitle(" Добавить в Календарь", for: .normal)
        addCalendarButton.setTitleColor(.red, for: .normal)
        view.addSubview(addCalendarButton)
        addCalendarButton.pinLeft(to: scheduledDatePicker)
        addCalendarButton.pinTop(to: scheduledDatePicker.bottomAnchor, 10)
        addCalendarButton.tintColor = .red
        addCalendarButton.addTarget(self, action: #selector(checkBoxButtonTapped), for: .touchUpInside)
        addCalendarButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        addReminderButton.setImage(UIImage(systemName: "square"), for: .normal)
        addReminderButton.setImage(UIImage(systemName: "checkmark.square"), for: .selected)
        addReminderButton.setTitle(" Добавить в Напоминания", for: .normal)
        addReminderButton.setTitleColor(.red, for: .normal)
        view.addSubview(addReminderButton)
        addReminderButton.pinLeft(to: addCalendarButton)
        addReminderButton.pinTop(to: addCalendarButton.bottomAnchor, 5)
        addReminderButton.tintColor = .red
        addReminderButton.addTarget(self, action: #selector(checkBoxButtonTapped), for: .touchUpInside)
        addReminderButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        
        view.addSubview(durationLabel)
        durationLabel.pinTop(to: addReminderButton.bottomAnchor, 10)
        durationLabel.pinLeft(to: view, 30)
        durationLabel.text = "Продолжительность"
        durationLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
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
        durationHourLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
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
        durationMinuteLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        view.addSubview(descriptionLabel)
        descriptionLabel.setWidth(view.bounds.width)
        descriptionLabel.pinTop(to: durationMinuteLabel.bottomAnchor, 10)
        descriptionLabel.pinLeft(to: view, 30)
        descriptionLabel.text = "Описание"
        descriptionLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
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
        
        view.addSubview(tagLabel)
        tagLabel.pinTop(to: descriptionTextView.bottomAnchor, 10)
        tagLabel.pinLeft(to: view, 30)
        tagLabel.text = "Теги"
        tagLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        view.addSubview(addTagButton)
        let smallConfig = UIImage.SymbolConfiguration(scale: .medium)
        addTagButton.setImage(UIImage(systemName: "plus.circle", withConfiguration: smallConfig), for: .normal)
        addTagButton.tintColor = .red
        addTagButton.pinLeft(to: tagLabel.trailingAnchor, 5)
        addTagButton.pinCenterY(to: tagLabel)
        addTagButton.addTarget(self, action: #selector(addTagButtonTapped), for: .touchUpInside)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 15)
        tagsCollectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        tagsCollectionView.register(TagViewCell.self, forCellWithReuseIdentifier: TagViewCell.reuseIdentifier)
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        view.addSubview(tagsCollectionView)
        tagsCollectionView.pinHorizontal(to: view, 30)
        tagsCollectionView.pinTop(to: tagLabel.bottomAnchor, 10)
        tagsCollectionView.pinBottom(to: saveButton.topAnchor, 10)
        tagsCollectionView.allowsSelection = true
        tagsCollectionView.allowsMultipleSelection = true
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc private func checkBoxButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func addTagButtonTapped() {
        let addTagViewController = AddTagViewController()
        addTagViewController.modalPresentationStyle = .custom
        addTagViewController.transitioningDelegate = self
        addTagViewController.didFinishAddingTag = { [weak self] in
            self?.tagsCollectionView.reloadData()
        }
        present(addTagViewController, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty,
              let taskDescription = descriptionTextView.text, taskDescription != "Введите описание",
              let durationHoursText = durationHourTextField.text, let durationHours = Int64(durationHoursText),
              let durationMinutesText = durationMinuteTextField.text, let durationMinutes = Int64(durationMinutesText) else {
            showAlert(title: "Ошибка ввода", message: "Заполните все поля")
            return
        }
        let totalDuration = (durationHours * 60) + durationMinutes
        do {
            try presenter?.addTask(
                name: name,
                description: taskDescription,
                scheduledDate: scheduledDatePicker.date,
                duration: totalDuration,
                addToReminder: addReminderButton.isSelected,
                addToCalendar: addCalendarButton.isSelected,
                tagsIndexes: getSelectedCellsIndex()
            )
        } catch let error as NSError  {
            showAlert(title: "Ошибка сохранения", message: error.localizedDescription)
        }
        customBackTapped()
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in }
        
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func getSelectedCellsIndex() -> [Int] {
        guard let selectedIndexPaths = tagsCollectionView.indexPathsForSelectedItems else { return [] }
        return selectedIndexPaths.map { $0.row }
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

// MARK: - UICollectionViewDelegate
extension AddSpecificTaskViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                cell.layer.borderColor = UIColor.red.cgColor
                cell.layer.borderWidth = 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.3) {
            if let cell = collectionView.cellForItem(at: indexPath) {
                cell.transform = CGAffineTransform.identity
                cell.layer.borderColor = UIColor.clear.cgColor
                cell.layer.borderWidth = 0
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AddSpecificTaskViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.getTagsCount() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagViewCell.reuseIdentifier, for: indexPath)
        guard let tagViewCell = cell as? TagViewCell else { return cell }
        guard let tagDto = presenter?.getTag(index: indexPath.row) else { return cell }
        tagViewCell.configureTag(name: tagDto.name, color: UIColor(tagDto.color))
        
        return tagViewCell
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension AddSpecificTaskViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PopUpPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }
}
